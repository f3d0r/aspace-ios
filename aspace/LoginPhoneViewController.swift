//
//  LoginPhoneViewController.swift
//
//  Created by Fedor Paretsky on 10/2/18.
//  Copyright © 2018 aspace, Inc.. All rights reserved.
//
import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import PhoneNumberKit
import Intercom
import FlagPhoneNumber
import PMSuperButton

class LoginPhoneViewController: UIViewController {
    
    var phoneNumberTextField: FPNTextField!
    var loginButton: UIButton!
    @IBOutlet weak var straightToMapButton: PMSuperButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: PHONE NUMBER TEXT FIELD SET UP
        phoneNumberTextField = FPNTextField(frame: CGRect(x: 0, y: view.frame.height/2, width: view.frame.width - 60, height: 50))
        phoneNumberTextField.layer.cornerRadius = 0;
        phoneNumberTextField.layer.masksToBounds = true;
        phoneNumberTextField.borderStyle = .roundedRect
        phoneNumberTextField.backgroundColor = UIColor.white
        phoneNumberTextField.parentViewController = self
        phoneNumberTextField.flagPhoneNumberDelegate = self
        phoneNumberTextField.setCountries(including: [.US, .CA])
        view.addSubview(phoneNumberTextField)
        
        //MARK: LOGIN BUTTON SET UP
        loginButton = UIButton(type: UIButton.ButtonType.system) as UIButton
        loginButton.frame = CGRect(x: 100, y: 100, width: 100, height: 50)
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.cornerRadius = 5.0
        loginButton.setTitle("Login", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(confirmPhone), for: .touchUpInside)
        
        self.view.addSubview(loginButton)
        let widthContraint =  NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 60)
        let heightContraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        let xContraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: phoneNumberTextField, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let yContraint = NSLayoutConstraint(item: loginButton, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: phoneNumberTextField, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([heightContraint, widthContraint, xContraint, yContraint])
        
        //MARK: STRAIGHT TO MAP BUTTON SET
        let straightToMapLeadingConstraint = NSLayoutConstraint(item: straightToMapButton, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 25)
        let straightToMapTrailingConstraint = NSLayoutConstraint(item: straightToMapButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -25)
        let straightToMapTopConstraint = NSLayoutConstraint(item: straightToMapButton, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: phoneNumberTextField, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 50)
        let straightToMapHeightConstraint = NSLayoutConstraint(item: straightToMapButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 50)
        NSLayoutConstraint.activate([straightToMapLeadingConstraint, straightToMapTrailingConstraint, straightToMapTopConstraint, straightToMapHeightConstraint])
        straightToMapButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func confirmPhone(sender: UIButton!) {
        let phoneNumber = phoneNumberTextField.getRawPhoneNumber()
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let todoEndpoint: String = "https://api.trya.space/v1/auth/phone_login?phone_number=" + phoneNumber! + "&device_id=" + deviceId + "&call_verify=F"
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
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "LoginPinViewController") as! LoginPinViewController
                    newViewController.phoneNumber = phoneNumber
                    newViewController.deviceId = UIDevice.current.identifierForVendor!.uuidString
                    self.present(newViewController, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func straightToMapPressed(_ sender: Any) {
        if (!UserDefaults.standard.bool(forKey: "USER_REGISTERED")) {
            Intercom.registerUnidentifiedUser()
            UserDefaults.standard.set(true, forKey: "USER_REGISTERED")
        }
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! MapController
        newViewController.deviceId = UIDevice.current.identifierForVendor!.uuidString
        self.present(newViewController, animated: true, completion: nil)
    }
}

extension LoginPhoneViewController: FPNTextFieldDelegate {
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        textField.rightViewMode = .always
        if loginButton != nil {
            loginButton.isEnabled = isValid
        }
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        print(name, dialCode, code)
    }
}
