//
//  FormReference.swift
//  ReformCore
//
//  Created by Laszlo Korte on 25.09.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

struct StaticFormReference : Equatable {
    fileprivate let formId : FormIdentifier
    fileprivate let offset : Int


    init(formId: FormIdentifier, offset: Int) {
        self.formId = formId
        self.offset = offset
    }

    func getFormFor<R:Runtime>(_ runtime: R) -> Form? {
        guard let
            id = runtime.read(formId, offset: offset) else {
                return nil
        }

        return runtime.get(FormIdentifier(Int(id)))
    }

    func setFormFor<R:Runtime>(_ runtime: R, form: Form) {
        runtime.write(formId, offset: offset, value: UInt64(bitPattern: Int64(form.identifier.value)))

    }
}

func ==(lhs: StaticFormReference, rhs: StaticFormReference) -> Bool {
    return lhs.formId == rhs.formId && lhs.offset == rhs.offset
}
