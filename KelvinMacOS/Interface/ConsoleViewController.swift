//
//  ConsoleViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 2/6/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa
import Highlightr
import Kelvin

fileprivate let defaultDarkTheme = "agate"
fileprivate let defaultLightTheme = "default"
fileprivate let defaultLanguage = "kelvin" // "ruby" and "crystal" also works fine

class ConsoleViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet weak var outlineScrollView: NSScrollView!
    @IBOutlet var editorTextView: EditorTextView!
    @IBOutlet var consoleTextView: ConsoleTextView!
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
    var theme: String = defaultLightTheme {
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
        return storage
    }()
    
    /// The scope of the last successful compilation.
    /// It is used for code completion.
    var lastSuccessfulExecution: Scope?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegation
        editorTextView.delegate = self
        consoleTextView.consoleDelegate = self
        consoleTextView.delegate = self
        
        // Setup text views
        editorTextView.enabledTextCheckingTypes = 0
        editorTextView.layoutManager?.replaceTextStorage(editorTextStorage)
        editorTextView.setUpLineNumberView()
        
        // Use the theme that matches the current system appearance
        theme = view.isDarkMode() ? defaultDarkTheme : defaultLightTheme
        
        Program.io = self
        
        // Listen to the notif posted when switching between dark/light mode
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(themeChanged),
            name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"),
            object: nil
        )
    }
    
    @objc func themeChanged() {
        theme = view.isDarkMode() ? defaultDarkTheme : defaultLightTheme
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
        editorTextView.lineNumberView.backgroundColor = bgdColor
        
        // Set the color of cursor to the inverse of background color
        var c = editorTextView.backgroundColor
        c = c.usingColorSpace(.sRGB)!
        let r = 1 - c.redComponent
        let g = 1 - c.greenComponent
        let b = 1 - c.blueComponent
        let inverted = NSColor(calibratedRed: r, green: g, blue: b, alpha: 1)
        editorTextView.insertionPointColor = inverted
        editorTextView.lineNumberView.foregroundColor = inverted.withAlphaComponent(0.5)
        let grayScale = sqrt(pow(c.redComponent, 2) + pow(c.greenComponent, 2) + pow(c.blueComponent, 2))
        let alpha: CGFloat = grayScale > 0.5 ? 0.1 : 0.2
        let selectedTextAttributes = [
            NSAttributedString.Key.backgroundColor: textColor?.withAlphaComponent(alpha) ?? inverted.withAlphaComponent(alpha)
        ]
        editorTextView.selectedTextAttributes = selectedTextAttributes
        
        // Console text view
        consoleTextView.backgroundColor = bgdColor
        consoleTextView.font = font
        consoleTextView.textColor = textColor
        consoleTextView.selectedTextAttributes = selectedTextAttributes
        
        // Debugger text view
        debuggerTextView.backgroundColor = bgdColor
        debuggerTextView.font = font
        debuggerTextView.textColor = textColor
        debuggerTextView.selectedTextAttributes = selectedTextAttributes
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
            var program = try Compiler.shared.compile(document: sourceCode, workItem: workItem)
            log("compilation successful in \(time - t) seconds.")
            program.config = Program.Configuration(scope: .useDefault, retentionPolicy: .preserveAll)
            try program.run(workItem: workItem)
            lastSuccessfulExecution = Scope.current
            Scope.restoreDefault()
        } catch let e as KelvinError {
            log(e.localizedDescription)
        } catch let e {
            log("unexpected error: \(e.localizedDescription)")
        }
    }
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        guard textView === consoleTextView else {
            return true
        }
        if !consoleTextView.isReceivingInput || affectedCharRange.lowerBound <= consoleTextView.editableAfterCharAtIndex {
            return false
        }
        return true
    }
    
    func textDidChange(_ notification: Notification) {
        guard notification.object as? NSTextView === editorTextView else {
            return
        }
        execTask?.cancel()
        let sourceCode = self.editorTextView.string
        execTask = DispatchWorkItem {[unowned self] in
            self.compileAndRun(sourceCode, self.execTask)
        }
        editorTextView.complete(nil)
        programExecQueue.asyncAfter(deadline: .now() + 0.1, execute: execTask!)
    }
    
    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        guard textView === editorTextView else {
            return []
        }
        let str = editorTextView.string
        let startIdx = str.index(str.startIndex, offsetBy: charRange.lowerBound)
        let endIdx = str.index(str.startIndex, offsetBy: charRange.upperBound)
        let partialWord = String(editorTextView.string[startIdx..<endIdx])
        
        // Ignore symbols like +, -, !=, etc.
        if partialWord == "" || !partialWord.isAlphanumeric {
            return []
        }
        // Operations with name that begins with the partial word
        var grp1 = [Kelvin.Operation]()
        
        // Operations with name that contains the partial word
        var grp2 = [Kelvin.Operation]()
        
        let registeredOperations = lastSuccessfulExecution?.operations ?? Operation.registered
        for (key, value) in registeredOperations {
            let candidate = key.lowercased()
            let part = partialWord.lowercased()
            if candidate.starts(with: part) {
                grp1.append(contentsOf: value)
            } else if candidate.contains(part) {
                grp2.append(contentsOf: value)
            }
        }
        
        let g1 = lastSuccessfulExecution?.definitions.keys
            .filter {$0.lowercased().starts(with: partialWord.lowercased())}
            .sorted {$0 < $1} ?? []
        let g2 = grp1.sorted {$0.name < $1.name}
            .map {$0.description} // Sort in alphabetic order
        let g3 = grp2.sorted {$0.name < $1.name}
            .map {$0.description}
        
        return [g1, g2, g3].flatMap {$0}
    }
    
    enum Buffer {
        case console
        case debugger
    }
}
