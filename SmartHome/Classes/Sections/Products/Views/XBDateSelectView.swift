//
//  XBDateSelectView.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/2/25.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

class XBDateSelectView: UIView {
    
    lazy var datePck:UIDatePicker? = {
        let dPicker = UIDatePicker()
        dPicker.datePickerMode = .date;
        dPicker.frame = CGRect(x: 0.0, y: 0.0, width: dPicker.width, height: 250.0)
        return dPicker
    }()
    
    var labelTextColor:UIColor = UIColorHex("595757", 1.0) {
        didSet {
            yearLabel.textColor = labelTextColor
            monthLabel.textColor = labelTextColor
            dayLabel.textColor = labelTextColor
        }
    }
    
    var didPickDateBlock:((Date)->())?
    
    static let outerMargin = (25.0*UIRate)
    static let interMargin = (17.0*UIRate)
    
    private let areaWidth   = (SCREEN_WIDTH - 2*outerMargin - 2*interMargin)/3
    
    private let yearField = XBRoundedTextField()
    private let monthField = XBRoundedTextField()
    private let dayField  = XBRoundedTextField()
    private let textField = UITextField()
    
    private let yearLabel = UILabel()
    private let monthLabel = UILabel()
    private let dayLabel  = UILabel()
    
    private var selectButton:UIButton!
    private var btnClickTimes = 0
    
    var date:Date? {
        didSet {
            yearField.text = "\(date!.year)"
            monthField.text = "\(date!.month)"
            dayField.text   = "\(date!.day)"
        }
    }
    
    var beginDate:Date?
    
    lazy var toolbar:UIToolbar? = {
        let tool = UIToolbar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        tool.items = [doneButton]
        return tool
    }()
    
    //MARK: - Life Cycle
    
    deinit {
        textField.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let fieldW = areaWidth - yearLabel.width - 5
        let fieldH = 30.0
        yearField.width = fieldW
        yearField.height = CGFloat(fieldH)
        yearField.left = XBDateSelectView.outerMargin
        yearLabel.left = yearField.right + 5
        yearLabel.centerY = height * 0.5
        
        monthField.width = fieldW
        monthField.height = CGFloat(fieldH)
        monthField.left = yearLabel.right + XBDateSelectView.interMargin
        monthLabel.left = monthField.right + 5
        monthLabel.centerY = height * 0.5
        
        dayField.width = fieldW
        dayField.height = CGFloat(fieldH)
        dayField.left = monthLabel.right + XBDateSelectView.interMargin
        dayLabel.left = dayField.right + 5
        dayLabel.centerY = height * 0.5
        
        selectButton.right = dayField.right
        selectButton.centerY = dayField.centerY
        
    }
    
    //MARK: - Private
    
    private func setup() {
        commonInitField(yearField)
        commonInitField(monthField)
        commonInitField(dayField)
        
        dayField.textAlignment = .left
        textField.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(textField)

        
        commonInitLabel(yearLabel, NSLocalizedString("Y", comment: ""))
        commonInitLabel(monthLabel, NSLocalizedString("M", comment: ""))
        commonInitLabel(dayLabel, NSLocalizedString("D", comment: ""))
        
        setupButton()
        
    }
    
    private func commonInitField(_ textfield:XBRoundedTextField) {
        textfield.font = UIFontSize(14)
        textfield.textColor = UIColorHex("777777", 1.0)
        textfield.textAlignment = .center
        textfield.isEnabled = false
        addSubview(textfield)
    }
    
    private func commonInitLabel(_ label:UILabel, _ text:String) {
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColorHex("ffffff", 1.0)
        label.text = text
        label.sizeToFit()
        addSubview(label)
    }
    
    private func setupButton() {
        selectButton = UIButton(image: UIImage(named:"pullDownBtn"), backImage: nil, color: nil, target: self, sel: #selector(pickDate(_:)), title: "")
        selectButton.sizeToFit()
        addSubview(selectButton)
    }
    
    private func showCalendar() {
        self.datePck!.minimumDate = beginDate
        datePck!.date = date!
        textField.inputView = datePck
        textField.inputAccessoryView = self.toolbar
        textField.reloadInputViews()
    }
    
    //MARK: - 按钮事件
    @objc private func pickDate(_ btn:UIButton) {
        if textField.isFirstResponder == false {
            showCalendar()
            textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
    }
    
    @objc private func done() {
        textField.resignFirstResponder()
        self.date = datePck?.date
        if self.didPickDateBlock != nil {
            self.didPickDateBlock!(self.date!)
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: XBDateSelectViewDidSelectDate), object: date!)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if dayField.frame.contains(point) {
            return selectButton
        }
        return view
    }

}
