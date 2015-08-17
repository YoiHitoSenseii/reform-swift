//
//  RotateInstruction.swift
//  ReformCore
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformMath

public struct RotateInstruction : Instruction {
    public typealias PointType = LabeledPoint
    public typealias AngleType = protocol<RuntimeRotationAngle, Labeled>
    
    public var target : FormIdentifier? {
        return formId
    }
    
    let formId : FormIdentifier
    let angle : AngleType
    var fixPoint : PointType
    
    public init(formId: FormIdentifier, angle: AngleType, fixPoint: PointType) {
        self.formId = formId
        self.angle = angle
        self.fixPoint = fixPoint
    }
    
    public func evaluate(runtime: Runtime) {
        guard let form = runtime.get(formId) as? Rotatable else {
            runtime.reportError(.UnknownForm)
            return
        }
        guard let fix : Vec2d = fixPoint.getPositionFor(runtime) else {
            runtime.reportError(.InvalidFixPoint)
            return
        }
        guard let a : Angle = angle.getAngleFor(runtime) else {
            runtime.reportError(.InvalidAngle)
            return
        }
        
        form.rotator.rotate(runtime, angle: a, fix: fix)
    }
    
    
    public func getDescription(analyzer: Analyzer) -> String {        let formName = analyzer.get(formId)?.name ?? "???"
        
        return "Rotate \(formName) around \(fixPoint.getDescription(analyzer)) by \(angle.getDescription(analyzer))"
    }
    
    
    
    public func analyze(analyzer: Analyzer) {
    }
    
}