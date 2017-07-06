
//
//  XBEditUserInfoViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/14.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift
import Toast_Swift
import SVProgressHUD
import DropDown

class XBEditUserInfoViewController: UIViewController, UITextFieldDelegate, XBPhotoPickerManagerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var usernameTextField: XBTextField!
    @IBOutlet weak var firstnameField: XBTextField!
    @IBOutlet weak var middleNameField: XBTextField!
    @IBOutlet weak var lastnameField: XBTextField!
    @IBOutlet weak var birthField: XBTextField!
    @IBOutlet weak var birthButton: UIButton!
    @IBOutlet weak var genderField: XBTextField!
    @IBOutlet weak var phoneNumberField: XBTextField!
    @IBOutlet weak var addressField: XBTextField!
    @IBOutlet weak var passwordField: XBTextField!
    @IBOutlet weak var retypePasswordField: XBTextField!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let chooseGenderDropDown = DropDown()
    let token = XBLoginManager.shared.currentLoginData!.token
    
    var loginUser = XBUser()
    var avatarImage:UIImage?
    private var fullFilled:Bool = true
    private var photoManager:XBPhotoPickerManager?
    
    lazy var textfields:[UITextField]? = {
        return []
    }()
    
    lazy var dateFormatter:DateFormatter? = {
        let dateFmt = DateFormatter()
        
        dateFmt.dateFormat = SYS_LANGUAGE_CHINESE ? "yyyy/MM/dd" : "MM/dd/yyyy"
        return dateFmt
    }()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollView.contentSize = CGSize(width: 0, height: backgroundView.top + backgroundView.height + CGFloat(71))
        
        photoManager = XBPhotoPickerManager.shared
        photoManager?.delegate = self
        
        setupDropDown()
        setupTextField()
        setupAvatar()
        
        backButton.layer.cornerRadius = backButton.height * 0.5
        submitButton.layer.cornerRadius = submitButton.height * 0.5
        avatarView.layer.cornerRadius = avatarView.height * 0.5
        avatarView.layer.masksToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    //MARK: - Setup
    private func setupTextField() {
        middleNameField.tag = -1
        addressField.tag = -1
        genderField.tag = -1
        birthField.tag = -1
        
        findTextfield {[weak self] in
            self!.textfields?.append($0)
        }
        
        let pwd = XBLoginManager.shared.currentLoginData?.password
        usernameTextField.text = loginUser.email
        firstnameField.text = loginUser.firstName
        middleNameField.text = loginUser.middleName
        lastnameField.text =  loginUser.lastName
        birthField.text = loginUser.birthDay
        genderField.text = XBUserManager.genderForInt(loginUser.gender)
        phoneNumberField.text = loginUser.mphone
        addressField.text = loginUser.address
        passwordField.text = pwd
        retypePasswordField.text = pwd
        
        for tf in self.textfields! {
            if tf.text != "" {
                tf.textColor = UIColorHex("8a847f", 1.0)
            }
        }
    
        usernameTextField.isEnabled = false
    }
    
    private func setupAvatar() {
        avatarView.setHeader(url: loginUser.image, uid: loginUser.email)
        avatarView.isUserInteractionEnabled = true
        let tapAvatarGR = UITapGestureRecognizer.init(target: self, action: #selector(pickAvatar(_:)))
        avatarView.addGestureRecognizer(tapAvatarGR)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.textColor = XB_DARK_TEXT
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
        } else if (textField == genderField) {
            showGenderSelectView()
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.inputView != nil {
            let pickerView = textField.inputView as! UIDatePicker
            textField.text = self.dateFormatter?.string(from: pickerView.date)
        }
    }
    
    //MARK: - Action
    @IBAction func submit(_ sender: UIButton) {
        if (!fullFilled) {
            self.view.makeToast(NSLocalizedString("Please enter full information", comment: ""))
            return
        }
        view.endEditing(true)
        
        if !XBOperateUtils.validatePassword(passwordField.text!, confirmPwd: retypePasswordField.text!) {
            return
        }
        
        let email = usernameTextField.text!
        let pwd = passwordField.text!
        let gender = "\(XBUserManager.integerForGender(genderField.text!))"
        let params:Parameters = [
            "email":email,
            "password":pwd,
            "firstName":firstnameField.text!,
            "middleName":middleNameField.text ?? "",
            "lastName":lastnameField.text!,
            "birth":birthField.text!,
            "gender":gender,
            "mphone":phoneNumberField.text!,
            "address":addressField.text ?? "",
            "token":token
        ]
        
        var imageFiles = [UIImage]()
        if let image = avatarImage {
            imageFiles.append(image)
        }
        
        SVProgressHUD.show()
        XBNetworking.share.upload(imageFiles,
                                  url: MODIFY,
                                  maxLength: 100,
                                  params: params,
                                  success: { (json) in
                                    
                                    if json[Code].intValue == 1 {
                                        XBUserManager.shared
                                        .fetchUserFromServer(token: self.token,
                                                            handler: { (user, error) in
                                                                //登录信息本地缓存
                                                                let loginData = LoginData(account: email,
                                                                                          password: pwd,
                                                                                          token: self.token)
                                                                XBLoginManager.shared.currentLoginData = loginData
                                                                self.back(self.backButton)
                                        })
                                    } else {
                                        let message = json[Message].stringValue
                                        SVProgressHUD.showError(withStatus: message)
                                    }
                                    
        })
        { (error) in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
        }
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController!.popViewController(animated: true)
    }
    
    @IBAction func fillBirthday(_ sender: UIButton) {
        birthField.becomeFirstResponder()
        showCalendar()
    }
    
    //MARK: - Private
    @objc private func pickAvatar(_ sender: UIButton) {
        photoManager?.pickIn(vc: self)
    }
    
    private func showCalendar() {
        var dateStr:String = ""
        if birthField.isBlank() {
            let now = Date()
            dateStr = "\(now.month)/\(now.day)/\(now.year-50)"
        } else {
            dateStr = birthField.text!
        }
        if let date = self.dateFormatter!.date(from: dateStr) {
            datePicker!.date = date
            birthField.inputView = datePicker
            birthField.reloadInputViews()
        } else {
            print("日期格式转化错误！")
        }
    }
    
    private func showGenderSelectView() {
        genderField.resignFirstResponder()
        chooseGenderDropDown.show()
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
    
    private func onTextChanged() {
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
    
    //MARK: - XBPhotoPickerManagerDelegate
    func imagePickerDidFinishPickImage(image: UIImage) {
        
        avatarImage = image
        avatarView.image = image
    }
    
}

extension XBEditUserInfoViewController {
    
    func setupDropDown() {
        setupChooseGenderDropDown()
    }
    
    private func setupChooseGenderDropDown() {
        configDropDown(chooseGenderDropDown, [NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")], genderField)
    }
    
    private func configDropDown(_ dropDown:DropDown, _ datasource:Array<String>, _ anchorField:UITextField) {
        
        dropDown.anchorView = anchorField
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorField.bounds.height)
        
        dropDown.dataSource = datasource
        
        dropDown.selectionAction = { (index, item) in
            anchorField.text = item
        }
        
        dropDown.dismissMode = .onTap
        dropDown.direction = .any
    
    }
    
}
