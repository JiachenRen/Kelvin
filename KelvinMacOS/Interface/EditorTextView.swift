//
//  EditorTextView.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/19/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Cocoa

class EditorTextView: NSTextView {
    
    private var isSelecting: Bool = false
    
    override func insertCompletion(
        _ word: String,
        forPartialWordRange charRange: NSRange,
        movement: Int,
        isFinal flag: Bool) {
        
        func complete() {
            super.insertCompletion(
                word,
                forPartialWordRange: charRange,
                movement: movement,
                isFinal: flag
            )
        }
        
        switch movement {
        case 17: // Tab
            complete()
        case 16 where isSelecting: // Return
            complete()
        case 21, 22:
            isSelecting = true
            return
        default:
            break
        }
        
        isSelecting = false
        
    }
    
}
