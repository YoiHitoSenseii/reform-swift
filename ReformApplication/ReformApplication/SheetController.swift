//
//  SheetController.swift
//  ReformApplication
//
//  Created by Laszlo Korte on 14.08.15.
//  Copyright © 2015 Laszlo Korte. All rights reserved.
//

import Foundation
import Cocoa

final class SheetController : NSViewController {
    @IBOutlet var tableView : NSTableView?
}


extension SheetController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 3
    }
}

extension SheetController : NSTableViewDelegate {
   
}
