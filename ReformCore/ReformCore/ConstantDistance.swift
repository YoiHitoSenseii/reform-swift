//
//  ConstantDistance.swift
//  ReformCore
//
//  Created by Laszlo Korte on 19.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct ConstantDistance : RuntimeDistance, Labeled {
    public typealias PointType = RuntimePoint & Labeled
    
    public let delta: Vec2d
    
    public init(delta: Vec2d) {
        self.delta = delta
    }
    
    public func getDeltaFor<R:Runtime>(_ runtime: R) -> Vec2d? {
        return delta
    }
    
    public func getDescription(_ stringifier: Stringifier) -> String {
        return delta.label
    }
    


    public var isDegenerated : Bool {
        return delta.x == 0 && delta.y == 0
    }
}

func combine(distance a: ConstantDistance, distance b: ConstantDistance) -> ConstantDistance {
    return ConstantDistance(delta: a.delta + b.delta)
}
