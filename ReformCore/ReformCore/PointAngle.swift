//
//  PointAngle.swift
//  ReformCore
//
//  Created by Laszlo Korte on 22.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

struct PointAngle : RuntimeRotationAngle {
    fileprivate let center : RuntimePoint
    fileprivate let point : RuntimePoint
    
    init(center: RuntimePoint, point: RuntimePoint) {
        self.center = center
        self.point = point
    }
    
    func getAngleFor<R:Runtime>(_ runtime: R) -> Angle? {
        guard let c = center.getPositionFor(runtime),
            let p = point.getPositionFor(runtime) else {
                return nil
        }
        return normalize360(angle(p-c))
    }
    
    var isDegenerated : Bool {
        return false
    }
}


extension PointAngle : Equatable {
}

func ==(lhs: PointAngle, rhs: PointAngle) -> Bool {
    return lhs.center.isEqualTo(rhs.center) && lhs.point.isEqualTo(rhs.point)
}
