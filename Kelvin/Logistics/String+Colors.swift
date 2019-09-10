//
//  Colors.swift
//  Colors
//
//  Created by Chad Scira on 3/3/15.
//  Copyright (c) 2015 Chad Scira. All rights reserved.
//

import Foundation

fileprivate var colorCodes:[String:Int] = [
    "black": 30,
    "red": 31,
    "green": 32,
    "yellow": 33,
    "blue": 34,
    "magenta": 35,
    "cyan": 36,
    "white": 37
]

fileprivate var bgColorCodes:[String:Int] = [
    "blackBackground": 40,
    "redBackground": 41,
    "greenBackground": 42,
    "yellowBackground": 43,
    "blueBackground": 44,
    "magentaBackground": 45,
    "cyanBackground": 46,
    "whiteBackground": 47
]

fileprivate var styleCodes:[String:Int] = [
    "reset": 0,
    "bold": 1,
    "italic": 3,
    "underline": 4,
    "inverse": 7,
    "strikethrough": 9,
    "boldOff": 22,
    "italicOff": 23,
    "underlineOff": 24,
    "inverseOff": 27,
    "strikethroughOff": 29
]

fileprivate func getCode(_ key: String) -> Int? {
    if colorCodes[key] != nil {
        return colorCodes[key]
    }
    else if bgColorCodes[key] != nil {
        return bgColorCodes[key]
    }
    else if styleCodes[key] != nil {
        return styleCodes[key]
    }
    
    return nil
}

fileprivate func addCodeToCodesArray(_ codes: Array<Int>, code: Int) -> Array<Int> {
    var result:Array<Int> = codes
    
    if colorCodes.values.contains(code) {
        result = result.filter { !colorCodes.values.contains($0) }
    }
    else if bgColorCodes.values.contains(code) {
        result = result.filter { !bgColorCodes.values.contains($0) }
    }
    else if code == 0 {
        return []
    }
    
    if !result.contains(code) {
        result.append(code)
    }
    
    return result
}

fileprivate func matchesForRegexInText(_ regex: String!, text: String!, global: Bool = false) -> [String] {
    let regex = try! NSRegularExpression(pattern: regex, options: [])
    let nsString = text as NSString
    let results = regex.matches(in: nsString as String, options: [], range: NSMakeRange(0, nsString.length))
    
    if !global && results.count == 1 {
        var result:[String] = []
        
        for i in 0..<results[0].numberOfRanges {
            result.append(nsString.substring(with: results[0].range(at: i)))
        }
        
        return result
    }
    else {
        return results.map { nsString.substring(with: $0.range) }
    }
}

fileprivate struct ANSIGroup {
    var codes:[Int]
    var string:String
    
    func toString() -> String {
        let codeStrings = codes.map { String($0) }
        return "\u{001B}[" + codeStrings.joined(separator: ";") + "m" + string + "\u{001B}[0m"
    }
}

fileprivate func parseExistingANSI(_ string: String) -> [ANSIGroup] {
    var results:[ANSIGroup] = []
    
    let matches = matchesForRegexInText("\\u001B\\[([^m]*)m(.+?)\\u001B\\[0m", text: string, global: true)
    
    for match in matches {
        let parts = matchesForRegexInText("\\u001B\\[([^m]*)m(.+?)\\u001B\\[0m", text: match)
        let codes = parts[1].split {$0 == ";"}.map { String($0) }
        let string = parts[2]
        
        results.append(ANSIGroup(codes: codes.filter { Int($0) != nil }.map { Int($0)! }, string: string))
    }
    
    return results
}

fileprivate func format(_ string: String, _ command: String) -> String {
    
    if (ProcessInfo.processInfo.environment["DEBUG"] != nil && ProcessInfo.processInfo.environment["DEBUG"]! as String == "true" && (ProcessInfo.processInfo.environment["TEST"] == nil || ProcessInfo.processInfo.environment["TEST"]! as String == "false")) {
        return string
    }
    
    let code = getCode(command)
    let existingANSI = parseExistingANSI(string)
    
    if code == nil {
        return string
    } else if existingANSI.count > 0 {
        return existingANSI.map {
            return ANSIGroup(codes: addCodeToCodesArray($0.codes, code: code!), string: $0.string).toString()
            }.joined(separator: "")
    } else {
        let group = ANSIGroup(codes: [code!], string: string)
        return group.toString()
    }
}

public extension String {
    // foregrounds
    var black: String {
        return format(self, "black")
    }
    var red: String {
        return format(self, "red")
    }
    var green: String {
        return format(self, "green")
    }
    var yellow: String {
        return format(self, "yellow")
    }
    var blue: String {
        return format(self, "blue")
    }
    var magenta: String {
        return format(self, "magenta")
    }
    var cyan: String {
        return format(self, "cyan")
    }
    var white: String {
        return format(self, "white")
    }
    
    // backgrounds
    var blackBackground: String {
        return format(self, "blackBackground")
    }
    var redBackground: String {
        return format(self, "redBackground")
    }
    var greenBackground: String {
        return format(self, "greenBackground")
    }
    var yellowBackground: String {
        return format(self, "yellowBackground")
    }
    var blueBackground: String {
        return format(self, "blueBackground")
    }
    var magentaBackground: String {
        return format(self, "magentaBackground")
    }
    var cyanBackground: String {
        return format(self, "cyanBackground")
    }
    var whiteBackground: String {
        return format(self, "whiteBackground")
    }
    
    // formats
    var bold: String {
        return format(self, "bold")
    }
    
    var italic: String {
        return format(self, "italic")
    }
    
    var underline: String {
        return format(self, "underline")
    }
    
    var reset: String {
        return format(self, "reset")
    }
    
    var inverse: String {
        return format(self, "inverse")
    }
    
    var strikethrough: String {
        return format(self, "strikethrough")
    }
    
    var boldOff: String {
        return format(self, "boldOff")
    }
    
    var italicOff: String {
        return format(self, "italicOff")
    }
    
    var underlineOff: String {
        return format(self, "underlineOff")
    }
    
    var inverseOff: String {
        return format(self, "inverseOff")
    }
    
    var strikethroughOff: String {
        return format(self, "strikethroughOff")
    }
}
