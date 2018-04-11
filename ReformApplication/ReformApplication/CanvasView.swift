//
//  CanvasView.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

import ReformGraphics
import ReformMath
import ReformStage
import ReformTools


@IBDesignable
final class CanvasView : NSView {
    @IBOutlet weak var delegate : NSViewController?

    var canvasSize = Vec2d(x: 100, y: 100) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var camera : Camera? = nil
    var renderers : [Renderer] = []


    private var currentContext : CGContext? {
        get {
            return NSGraphicsContext.current?.cgContext

//             The 10.10 SDK provides a CGContext on NSGraphicsContext, but
//             that's not available to folks running 10.9, so perform this
//             violence to get a context via a void*.
//             iOS can just use UIGraphicsGetCurrentContext.
//            if #available(OSX 10.10, *) {
//                return NSGraphicsContext.currentContext()?.CGContext
//            } else {
//                let unsafeContextPointer = NSGraphicsContext.currentContext()?.graphicsPort
//                
//                if let contextPointer = unsafeContextPointer {
//                    let opaquePointer = COpaquePointer(contextPointer)
//                    let context: CGContextRef = Unmanaged.fromOpaque(opaquePointer).takeUnretainedValue()
//                    return context
//                } else {
//                    return nil
//                }
//            }
        }
    }

    
    override func draw(_ dirtyRect: NSRect) {
        if let context = currentContext {
            if let camera = camera {
                camera.zoom = Double(self.convert(NSSize(width:1, height: 1), to: nil).width)
            }

            let offsetX = (bounds.width-CGFloat(canvasSize.x))/2.0
            let offsetY = (bounds.height-CGFloat(canvasSize.y))/2.0
            context.translateBy(x: offsetX, y: offsetY)

            for r in renderers {
                r.renderInContext(context)
            }
        }
    }

    override var intrinsicContentSize : NSSize {
        return NSSize(width: canvasSize.x + 50, height: canvasSize.y + 50)
    }

    override var acceptsFirstResponder : Bool { return true }

    override func keyDown(with theEvent: NSEvent) {
        delegate?.keyDown(with: theEvent)
    }

    override func keyUp(with theEvent: NSEvent) {
        delegate?.keyUp(with: theEvent)
    }

    override func selectAll(_ sender: Any?) {
        delegate?.selectAll(sender)
    }

}
