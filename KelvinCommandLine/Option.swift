//
//  Option.swift
//  KelvinCommandLine
//
//  Created by Jiachen Ren on 2/2/19.
//  Copyright © 2019 Jiachen Ren. All rights reserved.
//

import Foundation

public enum Option: String {
    case colored = "c"
    case expression = "e"
    case file = "f"
    case verbose = "v"
    case verboseAndColored = "vc"
    
    public static func resolve(_ raw: String) throws -> Option {
        var raw = raw
        raw.removeFirst()
        
        guard let option = Option(rawValue: raw) else {
            print("Unrecognized option: \(raw)")
            Console.printUsage()
            exit(EXIT_FAILURE)
        }
        
        return option
    }
}
