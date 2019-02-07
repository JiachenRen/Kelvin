//
//  EditorSplitViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa

class EditorSplitViewController: NSSplitViewController {

    var editorViewController: EditorViewController {
        return splitViewItems.first!.viewController as! EditorViewController
    }
    
    var consoleViewController: ConsoleViewController {
        return splitViewItems.last!.viewController as! ConsoleViewController
    }
    
    var workItem: DispatchWorkItem?
    let execQueue = DispatchQueue(label: "com.jiachenren.Kelvin")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorViewController.delegate = self
        consoleViewController.delegate = self
    }
    
}

extension EditorSplitViewController: EditorDelegate {
    func sourceCodeUpdated(_ code: String) {
        workItem?.cancel()
        workItem = DispatchWorkItem {
            self.consoleViewController.compileAndRun(code)
        }
        execQueue.asyncAfter(deadline: .now() + 0.1, execute: workItem!)
    }
}

extension EditorSplitViewController: ConsoleDelegate {
    
}
