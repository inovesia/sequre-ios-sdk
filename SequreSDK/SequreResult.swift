//
//  Result.swift
//  SequreSDK
//
//  Created by Kazao TM on 04/03/24.
//

import Foundation
import AVFoundation

public struct SequreResult {
    public var genuine: Bool = false
    public var score: Float = 0
    public var qr: String = ""
    var label: String = ""
    var timeline: String = ""
    var error: Error?
    var image: CGImage?
    public init() {
        
    }
}
