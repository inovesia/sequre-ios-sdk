//
//  EnvironmentManager.swift
//  SequreSDK
//
//  Created by Andi Septiadi on 01/08/24.
//

import Foundation

internal class EnvManager {
    var environment: SequreEnvironmentType
    
    static var shared: EnvManager = EnvManager(environment: SequreConfig.environment)
    
    init(environment: SequreEnvironmentType) {
        self.environment = environment
    }
    
    var baseURL: String {
        get {
            switch environment {
            case .demo: return "https://demo-mobile.sequre.id"
            case .staging: return "https://smobile.sequre.id"
            case .production: return "https://mobile.sequre.id"
            }
        }
    }
    
    var consumerURL: String {
        get { baseURL + "/api/consumer" }
    }
    
    var guestURL: String {
        get { baseURL + "/api/guest" }
    }
}
