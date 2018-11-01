//
//  UserDefaults.swift
//  aspace
//
//  Created by Fedor Paretsky on 11/1/18.
//  Copyright © 2018 aspace, Inc. All rights reserved.
//

import Foundation

struct Defaults {
    
    static let (phoneNumberKey, deviceIdKey, accessCodeKey) = ("PHONE_NUMBER", "DEVICE_ID", "ACCESS_CODE")
    static let userSessionKey = "aspace.trya.session"
    
    struct Model {
        var phoneNumber: String?
        var deviceId: String?
        var accessCode: String?
        
        init(_ json: [String: String]) {
            self.phoneNumber = json[phoneNumberKey]
            self.deviceId = json[deviceIdKey]
            self.accessCode = json[accessCodeKey]
        }
        
        func isValid() -> Bool {
            return accessCode?.count ?? 0 >= 5
        }
    }
    
    static var saveUserSession = { (phoneNumber: String, deviceId: String, accessCode: String) in
        UserDefaults.standard.set([phoneNumberKey: phoneNumber, deviceIdKey: deviceId, accessCodeKey: accessCode], forKey: userSessionKey)
    }
    
    static var getUserSession = { _ -> Model in
        return Model((UserDefaults.standard.value(forKey: userSessionKey) as? [String: String]) ?? [:])
    }(())
    
    static func clearUserData(){
        UserDefaults.standard.removeObject(forKey: userSessionKey)
    }
}
