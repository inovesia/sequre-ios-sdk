//
//  Result.swift
//  SequreSDK
//
//  Created by Kazao TM on 04/03/24.
//

import Foundation
import AVFoundation

public struct SequreResult: Identifiable, Hashable {
    public static func == (lhs: SequreResult, rhs: SequreResult) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    public var id: UUID
    
    public var genuine: Bool?
    public var score: Float?
    public var qr: String?
    public var label: String?
    var timeline: String = ""
    var error: Error?
    var image: CGImage?
    public init() {
        id = UUID()
    }
}
