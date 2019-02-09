//
//  ConsoleViewController+NSOutlineViewDataSource.swift
//  macOS Application
//
//  Created by Jiachen Ren on 2/8/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation
import Cocoa
import Highlightr

fileprivate let configs: [Configuration] = [
    .init(name: "Language", Language.supported),
    .init(name: "Theme", KTheme.available),
]

fileprivate let configCellId: NSUserInterfaceItemIdentifier = .init(rawValue: "ConfigCell")
fileprivate let optionCellId: NSUserInterfaceItemIdentifier = .init(rawValue: "OptionCell")

extension ConsoleViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let config = item as? Configuration {
            return config.options.count
        }

        return configs.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let config = item as? Configuration {
            return config.options[index]
        }
        
        return configs[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let config = item as? Configuration {
            return config.options.count > 0
        }
        
        return false
    }
}

extension ConsoleViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        
        if let config = item as? Configuration {
            view = outlineView.makeView(withIdentifier: configCellId, owner: self) as? NSTableCellView
            if let textField = view?.textField {
                textField.stringValue = config.name
            }
        } else if let option = item as? Option {
            if let optionView = outlineView.makeView(withIdentifier: optionCellId, owner: self) as? NSTableCellView {
                if let textField = optionView.textField {
                    textField.stringValue = option.name
                }
                view = optionView
            }
        }
        
        return view
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        if let option = outlineView.item(atRow: outlineView.selectedRow) as? Option {
            option.set(for: self)
        }
    }
    
}

class Configuration {
    let options: [Option]
    let name: String
    
    init(name: String, _ options: [Option]) {
        self.options = options
        self.name = name
    }
    
}

protocol Option: CustomStringConvertible {
    var name: String { get }
    func set(for controller: ConsoleViewController)
}

extension Option {
    var description: String {
        return name
    }
}

class Language: Option {
    let name: String
    static let highlightr = Highlightr()!
    
    static let supported: [Language] = {
        return highlightr.supportedLanguages().map {
            Language($0)
        }
    }()
    
    init(_ name: String) {
        self.name = name
    }
    
    func set(for controller: ConsoleViewController) {
        controller.language = name
    }
}

class KTheme: Option {
    let name: String
    
    static let available: [KTheme] = {
        let highlightr = Highlightr()!
        return highlightr.availableThemes().map {
            return KTheme($0)
            }.sorted {
                $0.name < $1.name
        }
    }()
    
    private init(_ name: String) {
        self.name = name
    }
    
    func set(for controller: ConsoleViewController) {
        controller.theme = name
    }
}
