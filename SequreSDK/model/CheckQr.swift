// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let checkQr = try? JSONDecoder().decode(CheckQr.self, from: jsonData)

import Foundation

// MARK: - CheckQrModel
struct CheckQrModel: Codable {
    let status: String?
    let code: Int?
    let data: CheckQrClass?
}

// MARK: - CheckQrClass
struct CheckQrClass: Codable {
    let qrcode, status, statusMapping: String?

    enum CodingKeys: String, CodingKey {
        case qrcode, status
        case statusMapping = "status_mapping"
    }
}
