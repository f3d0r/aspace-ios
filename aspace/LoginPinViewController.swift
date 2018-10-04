import UIKit
import PinCodeTextField

class LoginPinViewController: UIViewController {
    
    @IBOutlet weak var pinCodeEditText: PinCodeTextField!
    @IBOutlet weak var pinTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinCodeEditText.keyboardType = .numberPad
        let defaults = UserDefaults.standard
        let userPhoneNumber = defaults.string(forKey: "USER_PHONE_NUMBER")
        print("USERPHONE: ", userPhoneNumber)
    }
    @IBAction func confirmPIN(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "mapViewController") as! ViewController
        self.present(newViewController, animated: true, completion: nil)
    }
}
