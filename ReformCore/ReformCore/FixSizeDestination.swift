//
//  FixSizeDestination.swift
//  ReformCore
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct FixSizeDestination : RuntimeInitialDestination, Labeled {
    public typealias PointType = RuntimePoint & Labeled
    
    public let from: PointType
    public let delta: Vec2d
    public let alignment: RuntimeAlignment
    
    public init(from: PointType, delta: Vec2d, alignment: RuntimeAlignment = .leading) {
        self.from = from
        self.delta = delta
        self.alignment = alignment
    }
    
    public func getMinMaxFor<R:Runtime>(_ runtime: R) -> (Vec2d,Vec2d)? {
        guard let min = from.getPositionFor(runtime) else {
            return nil
        }
        
        return alignment.getMinMax(from: min, to: min + delta)
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        let fromLabel = from.getDescription(stringifier)
        
        switch alignment {
        case .centered:
            return "Around \(fromLabel) \(delta.label)"
        case .leading:
            return "From \(fromLabel) \(delta.label)"
        }
    }

    public var isDegenerated : Bool {
        return delta.x == 0 && delta.y == 0
    }
}
