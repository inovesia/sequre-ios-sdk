//
//  API.swift
//  Sequre
//
//  Created by Kazao TM on 21/07/23.
//

import Foundation
import Alamofire

class API: NSObject {
    static let url = "https://smobile.sequre.id/"
    
    static func checkQr(qrcode: String, onFinish: @escaping (CheckQrModel) -> Void) {
        AF.request("\(url)/api/check-qr", method: .post, parameters: ["qrcode": qrcode]).responseDecodable(of: CheckQrModel.self) { response in
            let response = response.value! as CheckQrModel
            return onFinish(response)
        }
    }
    
//    static func login(username: String, password: String, onFinish: @escaping (LoginModel) -> Void) {
//        AF.request("\(url)/login", method: .post, parameters: ["username": username, "password": password]).responseDecodable(of: LoginModel.self) { response in
//            let response = response.value! as LoginModel
//            if response.code == 200 {
//                UserDefaults.standard.set(response.data?.token, forKey: "token")
//                UserDefaults.standard.set(response.data?.email, forKey: "email")
//                UserDefaults.standard.set(response.data?.username, forKey: "username")
//                UserDefaults.standard.set(response.data?.fullname, forKey: "fullname")
//            }
//            return onFinish(response)
//        }
//    }
//    
//    static func scanQr(parameters: Parameters, onFinish: @escaping (ScanQrModel) -> Void) {
//        let headers: HTTPHeaders = [.authorization(bearerToken: UserDefaults.standard.string(forKey: "token")!)]
//        AF.request("\(url)/scan-qr", method: .post, parameters: parameters, headers: headers).responseDecodable(of: ScanQrModel.self) { response in
////            NSLog("response: \(response)")
//            guard let response = response.value else {
//                return onFinish(ScanQrModel())
//            }
//            return onFinish(response as ScanQrModel)
//        }
//    }
//    
//    static func scanLog(parameters: Parameters, onFinish: @escaping (ScanLogModel) -> Void) {
//        let headers: HTTPHeaders = [.authorization(bearerToken: UserDefaults.standard.string(forKey: "token")!)]
//        AF.request("\(url)/scan-log", method: .post, parameters: parameters, headers: headers).responseDecodable(of: ScanLogModel.self) { response in
//            let response = response.value! as ScanLogModel
//            return onFinish(response)
//        }
//    }
//    
//    static func scanHistory(page: Int, onFinish: @escaping (ScanHistoriesModel) -> Void) {
//        let headers: HTTPHeaders = [.authorization(bearerToken: UserDefaults.standard.string(forKey: "token")!)]
//        AF.request("\(url)/scan-history", method: .get, parameters: ["page": "\(page)"],headers: headers).responseDecodable(of: ScanHistoriesModel.self) { response in
//            let response = response.value! as ScanHistoriesModel
////            NSLog("response: \(response)")
//            return onFinish(response)
//        }
//    }
//    
//    static func totalScan(onFinish: @escaping (TotalScanModel) -> Void) {
//        let headers: HTTPHeaders = [.authorization(bearerToken: UserDefaults.standard.string(forKey: "token")!)]
//        AF.request("\(url)/total-scan", method: .get, headers: headers).responseDecodable(of: TotalScanModel.self) { response in
//            let response = response.value! as TotalScanModel
////            NSLog("response: \(response)")
//            return onFinish(response)
//        }
//    }
}
