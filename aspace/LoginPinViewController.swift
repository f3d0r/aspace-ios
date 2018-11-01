import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import PinCodeTextField
import Intercom

class LoginPinViewController: UIViewController {
    
    @IBOutlet weak var pinCodeEditText: PinCodeTextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var phoneNumber: String?
    var deviceId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinCodeEditText.keyboardType = .numberPad
    }
    @IBAction func confirmPIN(_ sender: Any) {
        let url = "https://api.trya.space/v1/auth/check_pin?phone_number=" + phoneNumber! + "&device_id=" + deviceId! + "&verify_pin=" + pinCodeEditText.text!
        Alamofire.request(url, method: .post, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                let resCode = json["res_info"]["code"]
                switch(resCode){
                case 22:
                    let accessCode = json["res_content"]["access_code"]
                    Defaults.saveUserSession(self.phoneNumber!, self.deviceId!, accessCode.string!)
                    Intercom.logout()
                    Intercom.registerUser(withUserId: self.deviceId!, email: self.phoneNumber!)
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! MapController
                    newViewController.deviceId = self.deviceId
                    newViewController.accessCode = accessCode.string
                    self.present(newViewController, animated: true, completion: nil)
                default:
                    print("error")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
