//
//  ConsoleViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa
import Highlightr

fileprivate let defaultTheme = "github"
fileprivate let defaultLanguage = "elixir" // "ruby" and "crystal" also works fine

class ConsoleViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var outlineScrollView: NSScrollView!
    @IBOutlet var editorTextView: NSTextView!
    @IBOutlet var consoleTextView: NSTextView!
    @IBOutlet var debuggerTextView: NSTextView!
    @IBOutlet weak var outlineView: NSOutlineView!
    
    /// Asynchronous task that updates the content of console and debugger
    /// as the program is being executed.
    var asyncUpdateTask: DispatchWorkItem?
    
    /// Asynchronous queue for executing Kelvin scripts.
    let programExecQueue = DispatchQueue(label: "com.jiachenren.Kelvin")
    
    /// Work item for executing Kelvin scripts
    var execTask: DispatchWorkItem?
    
    var time: TimeInterval {
        return Date().timeIntervalSince1970
    }
    
    /// Stores the output of the program, either in console buffer or debugger buffer.
    var buffers = [Buffer: String]() {
        didSet {
            asyncUpdateTask?.cancel()
            asyncUpdateTask = DispatchWorkItem {
                let textColor = self.textColor
                self.debuggerTextView.string = self.buffers[.debugger] ?? ""
                self.debuggerTextView.textColor = textColor
                self.consoleTextView.string = self.buffers[.console] ?? ""
                self.consoleTextView.textColor = textColor
            }
            
            // Delay 0.1 seconds to retain the ability to cancel asynchronous update
            // tasks that are too frequent.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: asyncUpdateTask!)
        }
    }
    
    /// Theme for the JS syntax highlighting engine.
    var theme: String = defaultTheme {
        didSet {
            editorTextStorage.highlightr.setTheme(to: theme)
            updateInterfaceByTheme()
        }
    }
    
    /// Language for the JS syntax highlighting engine.
    var language: String = defaultLanguage {
        didSet {
            editorTextStorage.language = language
            updateInterfaceByTheme()
        }
    }
    
    /// Live text storage for editor text view that highlights on the fly.
    var editorTextStorage: CodeAttributedString = {
        let storage = CodeAttributedString()
        storage.language = defaultLanguage
        storage.highlightr.setTheme(to: defaultTheme)
        return storage
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup text views
        editorTextView.delegate = self
        editorTextView.enabledTextCheckingTypes = 0
        editorTextView.layoutManager?.replaceTextStorage(editorTextStorage)
        updateInterfaceByTheme()
        
        Program.io = self
    }

    /// Derive text color from current theme and language
    var textColor: NSColor? {
        let attrStr = editorTextStorage.highlightr.highlight("hahaha", as: "swift")!
        let range = NSRange(location: 0, length: attrStr.length)
        let key = NSAttributedString.Key(rawValue: "NSColor")
        return attrStr.fontAttributes(in: range).filter {
            $0.key == key
        }.first?.value as? NSColor
    }
    
    /// Manually update the UI components to match the JS highlighter theme.
    private func updateInterfaceByTheme() {
        let theme = editorTextStorage.highlightr.theme!
        let bgdColor = theme.themeBackgroundColor!
        let font = theme.codeFont!
        let textColor = self.textColor
            
        // Editor text view
        editorTextView.backgroundColor = bgdColor
        
        // Set the color of cursor to the inverse of background color
        var c = editorTextView.backgroundColor
        c = c.usingColorSpace(.sRGB)!
        let r = 1 - c.redComponent
        let g = 1 - c.greenComponent
        let b = 1 - c.blueComponent
        let inverted = NSColor(calibratedRed: r, green: g, blue: b, alpha: 1)
        editorTextView.insertionPointColor = inverted
        
        // Console text view
        consoleTextView.backgroundColor = bgdColor
        consoleTextView.font = font
        consoleTextView.textColor = textColor
        
        // Debugger text view
        debuggerTextView.backgroundColor = bgdColor
        debuggerTextView.font = font
        debuggerTextView.textColor = textColor
    }
    
    /**
     Compile and run Kelvin scripts defined by `sourceCode`.
     - Note: This **must** be run on a **separate thread** to reduce latency.
     - Parameters:
        - sourceCode: The Kelvin script to be compiled and executed
        - workItem: The dispatch work item where the script is executed
     */
    private func compileAndRun(_ sourceCode: String, _ workItem: DispatchWorkItem!) {
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
        execTask?.cancel()
        let sourceCode = self.editorTextView.string
        execTask = DispatchWorkItem {[unowned self] in
            self.compileAndRun(sourceCode, self.execTask)
        }
        programExecQueue.asyncAfter(deadline: .now() + 0.1, execute: execTask!)
    }
    
    enum Buffer {
        case console
        case debugger
    }
}