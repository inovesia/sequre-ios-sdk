//
//  Result.swift
//  SequreSDK
//
//  Created by Kazao TM on 04/03/24.
//

import Foundation
import AVFoundation

public struct SequreResult {
    public var genuine: Bool?
    public var score: Float?
    public var qr: String?
    public var label: String?
    var timeline: String = ""
    var error: Error?
    var image: CGImage?
    public init() {
        
    }
}
