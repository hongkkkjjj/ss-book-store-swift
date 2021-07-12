//
//  UserDefaultUtil.swift
//  SS Book Store
//
//  Created by Soft Space User on 05/07/2021.
//

import Foundation

class UserDefaultUtil {
    private static let isUserLoginKey = "isUserLogin"
    
    static var isUserLogin: Bool {
        get {
            if UserDefaults.standard.object(forKey: isUserLoginKey) == nil {
                UserDefaults.standard.set(false, forKey: isUserLoginKey)
            }
            return UserDefaults.standard.bool(forKey: isUserLoginKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: isUserLoginKey)
        }
    }
}
