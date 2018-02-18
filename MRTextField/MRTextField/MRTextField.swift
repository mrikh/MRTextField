//
//  MRTextField.swift
//  MRTextField
//
//  Created by Mayank Rikh on 02/12/17.
//  Copyright © 2017 Mayank Rikh. All rights reserved.
//

import UIKit

protocol MRTextFieldDelegate : class{
    
    func userDidTapRightButton(_ sender : UIButton)
}

class MRTextField: UITextField {
    
    //to store in case of you start animating the button
    private var currentRightView : UIView?
    private var errorLabel : UILabel?
    private var floatingLabel : UILabel?
    private var floatingLabelBottomConstraint : NSLayoutConstraint?
    private var floatingLabelTopConstraint : NSLayoutConstraint?
    
    private enum LayerIdentifier : Int{
        
        case bottomBorder = 1001
    }

    @IBInspectable var bottomBorderColor : UIColor = UIColor.clear{
        didSet{
            updateBorderColor()
        }
    }
    
    @IBInspectable var showFloatingLabel : Bool = true
    
    @IBInspectable var floatingLabelColor : UIColor = #colorLiteral(red: 0.8209885955, green: 0.821634829, blue: 0.8407682776, alpha: 1){
        didSet{
            floatingLabel?.textColor = floatingLabelColor
        }
    }
    
    @IBInspectable var leftImage : UIImage? = nil{
        didSet{
            if let tempImage = leftImage{
                createLeftImageView(tempImage)
            }
        }
    }
    
    @IBInspectable var rightImage : UIImage? = nil{
        didSet{
            if let tempImage = rightImage{
                createRightImageView(tempImage)
            }
        }
    }
    
    weak var customDelegate : MRTextFieldDelegate?
    
    var regexString : String? = nil
    
    var errorString : String? = nil{
        didSet{
            errorLabel?.text = errorString
        }
    }
    
    var errorFont : UIFont? = nil{
        didSet{
            if let tempFont = errorFont{
                errorLabel?.font = tempFont
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        borderStyle = .none
        clipsToBounds = false
        setupBottomBorder()
        createErrorMessageLabel()
        setupFloatingLabel()
        
        addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let tempLayer = getLayerForIdentifier(LayerIdentifier.bottomBorder.rawValue){
            
            tempLayer.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        }
    }
    
    //MARK: Error message in case of validation
    func showErrorMessage(){
        
        if let tempLayer = getLayerForIdentifier(LayerIdentifier.bottomBorder.rawValue){
            tempLayer.backgroundColor = UIColor.red.cgColor
        }
        
        errorLabel?.text = errorString
        if let tempFont = errorFont{
            errorLabel?.font = tempFont
        }
        
        animateErrorLabel(1.0)
    }
    
    func hideErrorMessage(){
        
        if let tempLayer = getLayerForIdentifier(LayerIdentifier.bottomBorder.rawValue){
            tempLayer.backgroundColor = bottomBorderColor.cgColor
        }
        animateErrorLabel(0.0)
    }

    //MARK: Activity indicator on right side
    func startAnimating(){
        
        let activityIndicator = UIActivityIndicatorView()
        //hit and trial value
        activityIndicator.center.x = activityIndicator.center.x + 10.0
        activityIndicator.center.y = activityIndicator.center.y + 10.0
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        currentRightView = self.rightView
        
        self.rightView = createView(withView: activityIndicator)
    }
    
    func stopAnimating(){
        
        if self.rightView is UIActivityIndicatorView{
            
            let tempView = self.rightView as! UIActivityIndicatorView
            tempView.stopAnimating()
        }
        
        self.rightView = currentRightView
    }
    
    //MARK:- Private Functions
    @objc func textFieldDidChange(_ textField : UITextField){
        
        guard let text = textField.text else {return}
        
        if showFloatingLabel{
        
            if text.isEmpty{
                animateFloatingLabel(false)
            }else{
                animateFloatingLabel(true)
            }
        }
        
        checkForErrorString()
    }
    
    private func animateFloatingLabel(_ animate : Bool){
        
        guard let fontHeight = font?.lineHeight else {
            
            let alpha : CGFloat = animate ? 0.0 : 1.0
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = alpha
            })
            
            return
        }
        
        if animate{
            
            if let currentValue = floatingLabelTopConstraint?.constant, currentValue == 0.0{
            
                floatingLabelTopConstraint?.constant = -fontHeight - 5.0
                floatingLabelBottomConstraint?.constant = -fontHeight - 5.0
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.layoutIfNeeded()
                }, completion: { (finished) in
                    
                    UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: {
                        
                        self.floatingLabel?.textColor = self.floatingLabelColor
                    }, completion: nil)
                })
            }
        }else{
            
            if let currentValue = floatingLabelTopConstraint?.constant, currentValue != 0.0{
                
                floatingLabelTopConstraint?.constant = 0.0
                floatingLabelBottomConstraint?.constant = 0.0
                
                UIView.animate(withDuration: 0.3, animations: {
                    
                    self.layoutIfNeeded()
                }, completion: { (finished) in
                    
                    UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: {
                        
                        self.floatingLabel?.textColor = #colorLiteral(red: 0.8209885955, green: 0.821634829, blue: 0.8407682776, alpha: 1)
                    }, completion: nil)
                })
            }
        }
    }
    
    private func checkForErrorString(){
        
        guard let regexStr = regexString, let userText = text else {return}
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", regexStr)
        
        if passwordTest.evaluate(with: userText){
            
            if errorLabel?.alpha == CGFloat(1.0){
                hideErrorMessage()
            }
        }else{
            //show that we dont show multiple times
            if errorLabel?.alpha == CGFloat(0.0){
                showErrorMessage()
            }
        }
    }
    
    @objc func buttonAction(_ sender : UIButton){
        
        customDelegate?.userDidTapRightButton(sender)
    }
    
    private func animateErrorLabel(_ alpha : CGFloat){
        
        UIView.animate(withDuration: 0.25) {
            
            self.errorLabel?.alpha = alpha
        }
    }
    
    private func updateBorderColor(){
        
        if let tempLayer = getLayerForIdentifier(LayerIdentifier.bottomBorder.rawValue){
            tempLayer.backgroundColor = bottomBorderColor.cgColor
        }
    }
    
    private func getLayerForIdentifier(_ identifier : Int) -> CALayer?{
        
        if let tempSublayers = layer.sublayers{
            for sublayer in tempSublayers{
                if let value = sublayer.value(forUndefinedKey: "layerIdentifier") as? Int, value == identifier{
                    return sublayer
                }
            }
        }
        
        return nil
    }
}



//MARK:- Setup related part
extension MRTextField{
    
    //MARK: Setup button to perform some action like password etc on tap the action is passed in the delegate
    
    func setupButton(buttonIcon : UIImage?, andSelectedImage selectedImage : UIImage?, withText text: String?, withSelectedText selectedText : String?){
        
        let button = UIButton(frame: CGRect(x: 0, y: -1, width: 20, height: 20))
        
        button.setTitle(text, for: .normal)
        button.setTitle(selectedText, for: .selected)
        
        button.setImage(buttonIcon, for: .normal)
        button.setImage(selectedImage, for: .selected)
        
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        button.tag = self.tag
        
        rightViewMode = .always
        rightView = createView(withView: button)
    }
    
    fileprivate func setupFloatingLabel(){
        
        floatingLabel = UILabel()
        floatingLabel?.text = placeholder
        placeholder = nil
        floatingLabel?.textColor = #colorLiteral(red: 0.8209885955, green: 0.821634829, blue: 0.8407682776, alpha: 1)
        floatingLabel?.numberOfLines = 1
        floatingLabel?.font = UIFont.systemFont(ofSize: 14.0)
        floatingLabel?.alpha = 1.0
        
        addSubview(floatingLabel!)
        createConstraintsForFloatingLabel(floatingLabel!)
    }
    
    fileprivate func createErrorMessageLabel(){
        
        errorLabel = UILabel()
        
        errorLabel?.numberOfLines = 1
        errorLabel?.textColor = UIColor.red
        errorLabel?.font = UIFont.systemFont(ofSize: 12.0)
        errorLabel?.alpha = 0.0
        
        addSubview(errorLabel!)
        createConstraintsForLabel(errorLabel!)
    }
    
    fileprivate func createLeftImageView(_ image : UIImage){
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        self.leftViewMode = .always
        self.leftView = createView(withView: imageView)
    }
    
    fileprivate func createRightImageView(_ image : UIImage){
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        self.rightViewMode = .always
        self.rightView = createView(withView: imageView)
    }
    
    private func createView(withView view : UIView)->UIView{
        
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
        tempView.addSubview(view)
        return tempView
    }
    
    private func setupBottomBorder(){
        
        let bottomLayer = CALayer()
        
        bottomLayer.backgroundColor = bottomBorderColor.cgColor
        bottomLayer.frame = CGRect(x: 0, y: frame.height - 1, width: frame.width, height: 1)
        bottomLayer.setValue(LayerIdentifier.bottomBorder.rawValue, forKey: "layerIdentifier")
        layer.addSublayer(bottomLayer)
    }
    
    
    private func createConstraintsForLabel(_ label : UILabel){
        
        let dictionary = ["label" : label]
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var customConstraints = [NSLayoutConstraint]()
        customConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: .init(rawValue: 0), metrics: nil, views: dictionary))
        customConstraints.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 5.0))
        addConstraints(customConstraints)
    }
    
    private func createConstraintsForFloatingLabel(_ label : UILabel){
        
        let dictionary = ["label" : label]
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var customConstraints = [NSLayoutConstraint]()
        customConstraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: .init(rawValue: 0), metrics: nil, views: dictionary))
        
        floatingLabelTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0.0)
        customConstraints.append(floatingLabelTopConstraint!)
        floatingLabelBottomConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0.0)
        customConstraints.append(floatingLabelBottomConstraint!)
        
        addConstraints(customConstraints)
    }
}
