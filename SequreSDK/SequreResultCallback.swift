//
//  SequreResultCallback.swift
//  SequreSDK
//
//  Created by Kazao TM on 20/07/24.
//

import Foundation

public protocol SequreResultCallback {
    func onResult(result: SequreResult) -> Void
}
