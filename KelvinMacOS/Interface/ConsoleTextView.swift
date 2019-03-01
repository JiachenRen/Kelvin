//
//  ConsoleTextView.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/27/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa

class ConsoleTextView: NSTextView {
    weak var consoleDelegate: ConsoleDelegate?
    var editableAfterCharAtIndex = 0
    var isReceivingInput = false
    var handler: ((String) -> ())? = nil
    
    private func extractInput() -> String {
        let startIdx = string.index(string.startIndex, offsetBy: editableAfterCharAtIndex + 1)
        return String(string[startIdx..<string.endIndex])
    }
    
    func readLine(_ handler: @escaping (String) -> ()) {
        isReceivingInput = true
        editableAfterCharAtIndex = consoleDelegate?.editableAfterIndex() ?? 0
        self.handler = handler
    }
    
    func reset() {
        editableAfterCharAtIndex = 0
        isReceivingInput = false
        handler = nil
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36 where isReceivingInput:
            handler?(extractInput())
            reset()
        default:
            super.keyDown(with: event)
        }
        
        if isReceivingInput {
            let idx = editableAfterCharAtIndex + 1
            textStorage?.addAttributes(
                [NSAttributedString.Key.],
                range: NSRange(location: idx, length: string.count - idx)
            )
        }
    }
}

protocol ConsoleDelegate: AnyObject {
    func editableAfterIndex() -> Int
}
