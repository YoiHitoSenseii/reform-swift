//
//  EntitySelection.swift
//  ReformTools
//
//  Created by Laszlo Korte on 17.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import ReformCore
import ReformStage

public final class FormSelection {
    public fileprivate(set) var selected : Set<FormIdentifier> = Set()
    
    public init() {}
}


extension FormSelection {
    public var one : FormIdentifier? {
        if selected.count == 1 {
            return selected.first
        } else {
            return nil
        }
    }

    public func clear() {
        selected.removeAll()
    }

    public func select(_ formIds: Set<FormIdentifier>) {
        selected.removeAll()

        selected.formUnion(formIds)
    }

    public func select(_ formId: FormIdentifier) {
        selected.removeAll()

        selected.insert(formId)
    }
}
