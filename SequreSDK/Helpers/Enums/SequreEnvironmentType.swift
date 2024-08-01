//
//  SequreEnvironmentType.swift
//  SequreSDK
//
//  Created by Andi Septiadi on 01/08/24.
//

import Foundation

public enum SequreEnvironmentType: String {
    case demo = "DEMO"
    case staging = "STAG"
    case production = "PROD"
    
    public static func env(_ string: String) -> SequreEnvironmentType {
        guard let env = SequreEnvironmentType(rawValue: string)
        else { return SequreEnvironmentType.production }
        return env
    }
}
