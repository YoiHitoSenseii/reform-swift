//
//  Lexer.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

public struct SourcePosition : Hashable, CustomStringConvertible {
    let index : Int
    let row: Int
    let column: Int
    
    public var hashValue: Int {
        return 31*index + (31*row + (31*column))
    }
    
    public var description : String {
        return "row:\(row), col:\(column)"
    }
}

public func ==(lhs: SourcePosition, rhs: SourcePosition) -> Bool {
    return lhs.index == rhs.index && lhs.row == rhs.row && lhs.column == rhs.column
}



public protocol TokenType : Hashable {
    static var unknown : Self { get }
    static var ignore : Self { get }
    static var eof : Self { get }
}

public struct Token<T : TokenType> : Hashable, CustomStringConvertible {
    let position : SourcePosition
    let type : T
    let value : String
    
    public var hashValue: Int {
        return position.hashValue + type.hashValue + value.hashValue
    }
    
    public var description : String {
        return "\(type)(\(value))"
    }
}


public func ==<T>(lhs: Token<T>, rhs: Token<T>) -> Bool {
    return lhs.position == rhs.position && lhs.type == rhs.type && lhs.value == rhs.value
}

public struct LexerError : Error {
    let position : SourcePosition
    let string : String
}

public struct Lexer<T:TokenType> {
    let rules : [Rule<T>]
    let ignoreRules : [Rule<T>]
    
    public func tokenize(_ input: String) -> Tokens<T> {
        let lexer: Lexer<T> = self
        return Tokens(lexer: lexer, input: input)
    }
}

public struct Tokens<T: TokenType> : Sequence {
    private let lexer : Lexer<T>
    private let input : String
    
    init(lexer: Lexer<T>, input: String) {
        self.lexer = lexer
        self.input = input
    }
    
    public func makeIterator() -> TokenGenerator<T> {
        return TokenGenerator(lexer: lexer, input: input)
    }
}

public struct TokenGenerator<T : TokenType> : IteratorProtocol {
    private let lexer : Lexer<T>
    private let input : String
    
    private var index : Int = 1
    private var line : Int = 1
    private var column : Int = 1

    private var accFirst : Character? = nil
    private var accumulator : String = ""
    private var inputQueue = Queue<Character>()
    private var currentPos :  String.Index
    
    private var finished = false
    
    init(lexer : Lexer<T>, input: String) {
        self.lexer = lexer
        self.input = input
        currentPos = input.startIndex
    }
    
    
    public mutating func next() -> Token<T>? {
        var currentRule : Rule<T>?
        var currentPrio = 0
        var currentColumn = column
        var currentLine = line
        
        
        outer:
            while (true)
        {
            if (inputQueue.isEmpty)
            {
                if (currentPos < input.endIndex)
                {
                    inputQueue.add(input[currentPos])
                    currentPos = input.index(after: currentPos)
                }
                else if finished
                {
                    return nil
                } else {
                    break outer
                }
            }
            else if let peek = inputQueue.peek()
            {
                for rule in lexer.ignoreRules
                {
                    if (rule.matches(accumulator))
                    {
                        currentColumn = column
                        currentLine = line
                        index += accumulator.count
                        accumulator = ""
                        continue outer
                    }
                }
                
                var any = false
                for rule in lexer.rules
                {
                    let prio = lexer.rules.count - rule.inversePriority

                    if (prio >= currentPrio && rule.matches(
                        accumulator + String(peek)))
                    {
                        currentRule = rule
                        currentPrio = prio
                        any = true
                    }
                }
                if (!any)
                {
                    if (currentRule != nil)
                    {
                        break outer
                    }
                    currentRule = nil
                    currentPrio = 0
                }
                consume()
            }
        }
        
        if let r = currentRule
        {
            let current  = Token(position: SourcePosition(index: index, row: currentLine,
                column: currentColumn), type: r.type, value:
                accumulator)
            
            index += accumulator.count
            accumulator = ""
            
            return current
        }
        
        for rule in lexer.ignoreRules
        {
            if (rule.matches(accumulator))
            {
                currentColumn = column
                currentLine = line
                index += accumulator.count
                accumulator = ""
            }
        }
        
        if (!accumulator.isEmpty)
        {
            return Token(position: SourcePosition(index: index, row: currentLine, column: currentColumn), type: T.unknown, value: accumulator)
        }
        
        defer {
            finished = true
        }
        
        return Token(position: SourcePosition(index: index, row: currentLine, column: currentColumn), type: T.eof, value: "")
    }
    
    private mutating func consume()
    {
        if let peek = inputQueue.peek()
        {
            if (accumulator.isEmpty)
            {
                accFirst = peek
            }
            
            if(peek == "\n") {
                column = 1
                line += 1
            }
            else
            {
                column += 1
            }
            
            accumulator.append(peek)
            _ = inputQueue.poll()
        }
    }
}



public struct LexerGenerator<T:TokenType> {
    private var rules : [Rule<T>] = []
    private var ignoreRules : [Rule<T>] = []

    public init() {}

    public init(callback: (inout LexerGenerator<T>)->()) {
        callback(&self)
    }

    public mutating func add(_ type: T, pattern: String) {
        rules.append(Rule(type: type, pattern: pattern, inversePriority: rules.count))
    }
    
    public mutating func ignore(_ pattern: String) {
        ignoreRules.append(Rule(type: T.ignore, pattern: pattern, inversePriority: ignoreRules.count))
    }
    
    public func getLexer() -> Lexer<T> {
        return Lexer(rules: rules, ignoreRules: ignoreRules)
    }
}

struct Rule<T:TokenType>
{
    let type : T
    let pattern : String
    let inversePriority : Int
    
    init(type: T, pattern: String, inversePriority: Int) {
        self.type = type
        self.pattern = "\\A(\(pattern))\\Z"
        self.inversePriority = inversePriority
    }

    
    func matches(_ input : String) -> Bool
    {
        return input.range(of: pattern, options: .regularExpression) != nil
    }
    
}
