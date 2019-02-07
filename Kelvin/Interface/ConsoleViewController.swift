//
//  ConsoleViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa

class ConsoleViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet var editorTextView: NSTextView!
    @IBOutlet var consoleTextView: NSTextView!
    @IBOutlet var debuggerTextView: NSTextView!
    
    weak var delegate: ConsoleDelegate?
    var consoleOutput = "" {
        didSet {
            DispatchQueue.main.async {
                self.consoleTextView.string = self.consoleOutput
            }
        }
    }
    var debuggerOutput = "" {
        didSet {
            DispatchQueue.main.async {
                self.debuggerTextView.string = self.debuggerOutput
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorTextView.delegate = self
        editorTextView.enabledTextCheckingTypes = 0
        Program.io = self
    }
    
    var time: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    let programExecQueue = DispatchQueue(label: "com.jiachenren.Kelvin")
    var workItem: DispatchWorkItem?
    
    func compileAndRun(_ sourceCode: String, _ workItem: DispatchWorkItem!) {
        clear()
        do {
            log("compiling...")
            let t = time
            let program = try Compiler.compile(document: sourceCode, workItem: workItem)
            log("compilation successful in \(time - t) seconds.")
            try program.run(workItem: workItem)
        } catch let e as KelvinError {
            log(e.localizedDescription)
        } catch let e {
            log("unexpected error: \(e.localizedDescription)")
        }
    }
    
    func textDidChange(_ notification: Notification) {
        workItem?.cancel()
        let sourceCode = self.editorTextView.string
        workItem = DispatchWorkItem {[unowned self] in
            self.compileAndRun(sourceCode, self.workItem)
        }
        programExecQueue.asyncAfter(deadline: .now() + 0.1, execute: workItem!)
    }
    
}

extension ConsoleViewController: IOProtocol {
    
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
