//
//  LoginPhoneViewController.swift
//
//  Created by Fedor Paretsky on 10/2/18.
//  Copyright © 2018 aspace, Inc.. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import PhoneNumberKit

class LoginPhoneViewController: UIViewController {
    
    @IBOutlet weak var rawPhoneNumber: PhoneNumberTextField!
    @IBOutlet weak var confirmPhoneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rawPhoneNumber.keyboardType = .phonePad
        rawPhoneNumber.textContentType = UITextContentType.telephoneNumber;
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func confirmPhone(_ sender: UIButton) {
        let deviceId = UIDevice.current.identifierForVendor!.uuidString;
        let phoneNumber = rawPhoneNumber.nationalNumber
        let todoEndpoint: String = "https://api.trya.space/v1/auth/phone_login?phone_number=" + phoneNumber + "&device_id=" + deviceId + "&call_verify=F"
        Alamofire.request(todoEndpoint, method: .post, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if (json["res_info"]["code"] == 12) {
                    let alert = UIAlertController(title: "Phone Invalid", message: "Oops! Looks like that phone is invalid. Try again?", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                        case .cancel:
                            print("cancel")
                        case .destructive:
                            print("destructive")
                        }}))
                    self.present(alert, animated: true, completion: nil)
                } else if (json["res_info"]["code"] == 1 || json["res_info"]["code"] == 2) {
                    let defaults = UserDefaults.standard
                    defaults.set(self.rawPhoneNumber.nationalNumber, forKey: "USER_PHONE_NUMBER")
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "loginPinViewController") as! LoginPinViewController
                    self.present(newViewController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
