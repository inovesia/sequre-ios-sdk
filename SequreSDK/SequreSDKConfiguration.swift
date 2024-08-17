//
//  SequreSDKConfiguration.swift
//  SequreSDK
//
//  Created by Andi Septiadi on 01/08/24.
//

import Foundation

public final class SequreSDKConfiguration {
    public static func set(environment env: SequreEnvironmentType) {
        SequreConfig.environment = env
        
#if DEBUG
        print("=========================== SequreSDK ===========================")
        print("ENVIRONMENT: \(SequreConfig.environment)")
        print("=================================================================")
#endif
    }
    
    public static func set(zoomLevel level: CGFloat) {
        SequreConfig.zoomLevel = level
        
#if DEBUG
        print("=========================== SequreSDK ===========================")
        print("ZOOM LEVEL: \(SequreConfig.zoomLevel)")
        print("=================================================================")
#endif
    }
}
