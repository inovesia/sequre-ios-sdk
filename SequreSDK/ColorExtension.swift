//
//  ColorExtension.swift
//  SequreSDK
//
//  Created by Kazao TM on 04/03/24.
//

import SwiftUI

private class LocalColor {
  // only to provide a Bundle reference
}

public extension Color {
    static var clr_black2: Color {
        Color("clr_black2", bundle: Bundle(for: LocalColor.self))
    }
    static var clr_orange: Color {
        Color("clr_orange", bundle: Bundle(for: LocalColor.self))
    }
    static var clr_preview_background: Color {
        Color("clr_preview_background", bundle: Bundle(for: LocalColor.self))
    }
}
