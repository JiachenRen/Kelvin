//
//  ViewController.swift
//  Kelvin
//
//  Created by Jiachen Ren on 11/4/18.
//  Copyright © 2018 Jiachen Ren. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController, NSTextViewDelegate {

    @IBOutlet var editorTextView: NSTextView!
    weak var delegate: EditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editorTextView.delegate = self
        editorTextView.isAutomaticQuoteSubstitutionEnabled = false
    }

    func textDidChange(_ notification: Notification) {
        if let code = editorTextView.textStorage?.string {
            delegate?.sourceCodeUpdated(code)
        }
    }
}

protocol EditorDelegate: AnyObject {
    func sourceCodeUpdated(_ code: String)
}
