//
//  ConsoleViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController, NSTextViewDelegate, NSSplitViewDelegate {

    @IBOutlet var consoleTextView: NSTextView!
    @IBOutlet var debuggerTextView: NSTextView!
    @IBOutlet weak var splitView: NSSplitView!
    
    weak var delegate: ConsoleDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        consoleTextView.delegate = self
        splitView.delegate = self
        Program.io = self
    }
    
    var time: TimeInterval {
        return Date().timeIntervalSince1970
    }

    
    func compileAndRun(_ sourceCode: String) {
        clear()
        do {
            log("compiling...")
            let t = time
            let program = try Compiler.compile(document: sourceCode)
            log("compilation successful in \(time - t) seconds.")
            try program.run()
        } catch let e as KelvinError {
            log(e.localizedDescription)
        } catch let e {
            log("unexpected error: \(e.localizedDescription)")
        }
    }
    
}

extension ConsoleViewController: IOProtocol {
    
    private var consoleOutput: String {
        get {
            var content: String = ""
            let workItem = DispatchWorkItem {
                content = self.consoleTextView.string
            }
            DispatchQueue.main.async(execute: workItem)
            workItem.wait()
            return content
        }
        set {
            DispatchQueue.main.async {
                self.consoleTextView.string = newValue
            }
        }
    }
    
    // Inefficient code
    private var debuggerOutput: String {
        get {
            var content: String = ""
            let workItem = DispatchWorkItem {
                content = self.debuggerTextView.string
            }
            DispatchQueue.main.async(execute: workItem)
            workItem.wait()
            return content
        }
        set {
            DispatchQueue.main.async {
                self.debuggerTextView.string = newValue
            }
        }
    }
    
    private func format(_ n: Node) -> String {
        if let ks = n as? KString {
            return ks.string
        }
        return n.stringified
    }
    
    func readLine() -> String {
        return ""
    }
    
    func print(_ n: Node) {
        consoleOutput += format(n)
    }
    
    func println(_ n: Node) {
        consoleOutput += format(n) + "\n"
    }
    
    func log(_ l: String) {
        debuggerOutput += l + "\n"
    }
    
    func log(_ l: Program.Log) {
        debuggerOutput += "\t← \(format(l.input))\n"
        debuggerOutput += "\t→ \(format(l.output))\n"
    }
    
    func error(_ e: String) {
        debuggerOutput += e
    }
    
    func clear() {
        debuggerOutput = ""
        consoleOutput = ""
    }
    
    func flush() {
        
    }
    
}

protocol ConsoleDelegate: AnyObject {
    
}
