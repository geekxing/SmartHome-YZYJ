//
//  XBRegisterViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/23.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift
import SVProgressHUD
import DropDown

public protocol XBRegisterViewControllerDelegate:NSObjectProtocol {
    func regisDidComplete(account:String?, password pwd:String?)
}

let margin = 50.0

class XBRegisterViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - Properties
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var middleNameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var birthField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypePasswordField: UITextField!
    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    var fullFilled:Bool = false
    weak var delegate:XBRegisterViewControllerDelegate?
    
    lazy var textfields:[UITextField]? = {
       return []
    }()
    
    lazy var dateFormatter:DateFormatter? = {
        let dateFmt = DateFormatter()
        dateFmt.dateFormat = "MM/dd/yyyy"
        return dateFmt
    }()
    
    //MARK: - DropDown's

    let chooseGenderDropDown = DropDown()
    
    //MARK: - Life Cycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let classString = String(describing: type(of: self))
        super.init(nibName: nibNameOrNil ?? classString, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDropDowns()
        
        scrollView.contentSize = CGSize(width: 0, height: backgroundView.top + backgroundView.height + CGFloat(margin))
        adjustsScrollViewInsets_NO(scrollView: scrollView, vc: self)
        
        middleNameField.tag = -1
        addressField.tag = -1
        genderField.tag = -1
        birthField.tag = -1
        
        backButton.layer.cornerRadius = backButton.height * 0.5
        submitButton.layer.cornerRadius = submitButton.height * 0.5

        findTextfield {[weak self] in
            self!.textfields?.append($0)
            $0.setValue(UIColor.black, forKeyPath: "placeholderLabel.textColor")
            $0.setValue(UIFontSize(16), forKeyPath: "placeholderLabel.font")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" && textField.returnKeyType == .done {
            submit(submitButton)
            return false
        }
        return true
    }
    
    @objc private func textFieldDidChange(notification:NSNotification) {
        onTextChanged()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        onTextChanged()
        if textField == birthField {
            showCalendar()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == birthField {
            birthField.text = self.dateFormatter!.string(from: datePicker!.date)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            IQKeyboardManager.sharedManager().goNext()
        } else {
            submit(submitButton)
        }
        return true
    }

    //MARK: - Action
    
    @IBAction func selectGender(_ sender: UIButton) {
        self.view.endEditing(true)
        chooseGenderDropDown.show()
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if (!fullFilled || !checkboxButton.isSelected) {
            SVProgressHUD.showInfo(withStatus:NSLocalizedString("Please enter full information", comment: ""))
            return
        }
        view.endEditing(true)
        
        if !XBOperateUtils.validateEmail(usernameTextField.text!) {
            SVProgressHUD.showError(withStatus: NSLocalizedString("Email format error", comment: ""))
            return
        }
        if !XBOperateUtils.validatePassword(passwordField.text!, confirmPwd: retypePasswordField.text!) {
            return
        }
        
        let firstName = firstnameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let middleName = middleNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastnameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let gender = genderField.isBlank() ? "1" : "\(XBUserManager.integerForGender(genderField.text!))" //Default Gender Male
        var dateStr:String = ""
        if birthField.isBlank() {
            dateStr = "01/01/1970"    //Default Birth
        } else {
            dateStr = birthField.text!
        }
        
        let params:Parameters = [
            "email":usernameTextField.text!,
            "password":passwordField.text!,
            "firstName":firstName,
            "middleName":middleName ?? "",
            "lastName":lastName,
            "birth":dateStr,
            "gender":gender,
            "mphone":phoneNumberField.text!,
            "address":addressField.text ?? "",
        ]

        SVProgressHUD.show()
        XBNetworking.share.postWithPath(path: REGIST, paras: params,
            success: {[weak self] (json, message) in

                if json[Code].intValue == 1 {
                    SVProgressHUD.showSuccess(withStatus: message)
                    self!.delegate?.regisDidComplete(account: self?.usernameTextField.text, password: self?.passwordField.text)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: { [weak self] in
                        self?.back(self!.backButton)
                    })
                } else {
                    SVProgressHUD.showError(withStatus: message)
                }
            }, failure: { (error) in
                SVProgressHUD.showError(withStatus: error.localizedDescription)
        })
    }

    @IBAction func check(_ sender: UIButton) {
        checkboxButton.isSelected = !checkboxButton.isSelected
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController!.popViewController(animated: true)
    }
    
    //MARK: - Private
    
    private func showCalendar() {
        var date = Date().add(components: [.year:-50])
        if !birthField.isBlank() {
            if let dateFromStr = birthField.text!.date(format: .custom("MM/dd/yyyy"))?.absoluteDate {
                date = dateFromStr
            }
        }
        datePicker!.date = date
        birthField.inputView = datePicker
        birthField.reloadInputViews()
    }
    
    private func setAllTextFieldReturnType(type:UIReturnKeyType) {
        findTextfield {
            $0.returnKeyType = type
        }
    }
    
    private func findTextfield(complete:((_ textfield:UITextField) -> ())?) {
        for subview in view.subviews[2].subviews {
            if subview.isKind(of: UITextField.self) {
                let textField = subview as! UITextField
                if (complete != nil) {
                    complete!(textField)
                }
            }
        }
    }
    
    fileprivate func onTextChanged() {
        for tf in self.textfields! {
            let text = tf.text! as NSString
            if text.length == 0 && tf.tag != -1 {
                fullFilled = false
                break
            } else {
                fullFilled = true
            }
        }
        print(fullFilled)
        if fullFilled == false {
            setAllTextFieldReturnType(type: .next)
        } else {
            setAllTextFieldReturnType(type: .done)
        }
    }
    
}


//MARK: - DropDown
extension XBRegisterViewController {
    
    //MARK: - Setup
    
    func setupDropDowns() {
        setupChooseGenderDropDown()
    }

    private func setupChooseGenderDropDown() {
        configDropDown(chooseGenderDropDown, [NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")], genderField)
    }
    
    private func configDropDown(_ dropDown:DropDown, _ datasource:Array<String>, _ anchorField:UITextField) {
        
        dropDown.anchorView = anchorField
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorField.bounds.height)
        
        dropDown.dataSource = datasource
        
        dropDown.selectionAction = {[weak self] (index, item) in
            anchorField.text = item
            self?.onTextChanged()
        }
        
        dropDown.dismissMode = .onTap
        dropDown.direction = .any
    }
    
    
}
