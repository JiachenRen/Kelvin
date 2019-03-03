//
//  NSView+DarkMode.swift
//  macOS Application
//
//  Created by Jiachen Ren on 3/2/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import Cocoa

extension NSView {
    func isDarkMode() -> Bool {
        if #available(OSX 10.14, *) {
            return self.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return false
    }
}
