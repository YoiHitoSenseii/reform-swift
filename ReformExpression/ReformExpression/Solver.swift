//
//  Solver.swift
//  ExpressionEngine
//
//  Created by Laszlo Korte on 07.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

final public class Solver {
    let dataSet : WritableDataSet
    
    public init(dataSet: WritableDataSet) {
        self.dataSet = dataSet
    }
    
    public func evaluate(_ sheet : Sheet)
    {
        dataSet.clear()

        let (duplicates, definitions) = sheet.sortedDefinitions
        
        for defValue in definitions {
            let id = defValue.id
            
            switch defValue.value {
            case .array(_):
                fatalError()
            case .expr(let expr):
                let result = expr.eval(dataSet)
                switch result {
                case .success(let value):
                    dataSet.put(id, value: value)
                case .fail(let error):
                    dataSet.put(id, value: Value.intValue(value: 0))
                    dataSet.markError(id, error: error)
                }
            case .primitive(let value):
                dataSet.put(id, value: value)
            default:
                break
            }
        }
        
        for d in duplicates {
            dataSet.markError(d, error: EvaluationError.duplicateDefinition(referenceId: d))
        }
    
    }
}

final public class WritableDataSet : DataSet {
    var data : [ReferenceId:Value] = [ReferenceId:Value]()
    var errors: [ReferenceId:EvaluationError] = [ReferenceId:EvaluationError]()
    
    public init() {
    }
    
    public func lookUp(_ id: ReferenceId) -> Value? {
        return data[id]
    }
    
    public func getError(_ id: ReferenceId) -> EvaluationError? {
        return errors[id]
    }
    
    func put(_ id: ReferenceId, value: Value) {
        data[id] = value
    }
    
    func markError(_ id: ReferenceId, error: EvaluationError) {
        errors[id] = error
    }
    
    func clear() {
        errors.removeAll()
        data.removeAll()
    }
}
