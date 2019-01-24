//
//  String+Regex.swift
//  Kelvin
//
//  Created by Jiachen Ren on 1/23/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public struct Regex {
    var pattern: String {
        didSet {
            updateRegex()
        }
    }
    var expressionOptions: NSRegularExpression.Options {
        didSet {
            updateRegex()
        }
    }
    var matchingOptions: NSRegularExpression.MatchingOptions
    
    var regex: NSRegularExpression?
    
    init(pattern: String, expressionOptions: NSRegularExpression.Options, matchingOptions: NSRegularExpression.MatchingOptions) {
        self.pattern = pattern
        self.expressionOptions = expressionOptions
        self.matchingOptions = matchingOptions
        updateRegex()
    }
    
    init(pattern: String) {
        self.pattern = pattern
        expressionOptions = []
        matchingOptions = []
        updateRegex()
    }
    
    mutating func updateRegex() {
        regex = try! NSRegularExpression(pattern: pattern, options: expressionOptions)
    }
}


extension String {
    func matchRegex(pattern: Regex) -> Bool {
        let range: NSRange = NSMakeRange(0, count)
        if pattern.regex != nil {
            let matches: [AnyObject] = pattern.regex!.matches(in: self, options: pattern.matchingOptions, range: range)
            return matches.count > 0
        }
        return false
    }
    
    func match(patternString: String) -> Bool {
        return self.matchRegex(pattern: Regex(pattern: patternString))
    }
    
    func replaceRegex(pattern: Regex, template: String) -> String {
        if self.matchRegex(pattern: pattern) {
            let range: NSRange = NSMakeRange(0, count)
            if pattern.regex != nil {
                return pattern.regex!.stringByReplacingMatches(in: self, options: pattern.matchingOptions, range: range, withTemplate: template)
            }
        }
        return self
    }
    
    func replace(pattern: String, template: String) -> String {
        return self.replaceRegex(pattern: Regex(pattern: pattern), template: template)
    }
}

infix operator ~

public func ~(_ lhs: String, _ rhs: String) -> Bool {
    return lhs.match(patternString: rhs)
}

public func ~(_ lhs: String, _ rhs: Regex) -> Bool {
    return lhs.matchRegex(pattern: rhs)
}
