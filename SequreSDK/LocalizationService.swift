//
//  LocalizationService.swift
//  Sequre
//
//  Created by Bayu Aslama on 16/10/23.
//

import Foundation

class LocalizationService {

    static let shared = LocalizationService()
    static let changedLanguage = Notification.Name("changedLanguage")

    private init() {}
    
    
    var language: Language {
        get {
            let locale = Locale.current.languageCode
            let languagePrefix = Locale.preferredLanguages[0]
            let arr = languagePrefix.components(separatedBy: "-")
            let deviceLanguage = arr.first
            guard let languageString = UserDefaults.standard.string(forKey: "language") else {
             
                return deviceLanguage == "id" ? .indonesia : .english_us
            }
            return Language(rawValue: languageString) ?? .indonesia
        } set {
            if newValue != language {
                UserDefaults.standard.setValue(newValue.rawValue, forKey: "language")
                NotificationCenter.default.post(name: LocalizationService.changedLanguage, object: nil)
            }
        }
    }
}


enum Language: String {
    case english_us = "en"
    case indonesia = "id"
}
