//
//  ViewController.swift
//  ImagePicker
//
//  Created by Winona Azure on 6/26/16.
//  Copyright © 2016 Winona Azure. All rights reserved.
//

import UIKit

// struct for Meme object
struct Meme {
    var textField1: String
    var textField2: String
    var image: UIImage
    var memedImage: UIImage

}

class MemeMainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0
    ]
    
    // need a variable for our struct in this VC
    var meme: Meme?
    var memeObject: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable share button until you need it
        shareBarButton.enabled = false
        
        // set action icon for sharing button
        shareBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(self.shareMeme))
        navigationItem.leftBarButtonItem = shareBarButton
        
        // assign custom attributes to text fields
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // the notification center class adds an observer, which is a listener, waiting for notifications with the name UIKeyboardWillHideNotification. it also lists which function is listening for its broadcast, in this case: keyboardWillHide(_:)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeMainViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemeMainViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // assign delegates to text fields so the return key code will work
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // align manually, since the dictionary overrides text field properties
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // won't enable camera unless your phone has one
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
        
    }

    // one of two optional methods from UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController,
                        didFinishPickingMediaWithInfo info: [String : AnyObject]){
        
        // retreives image from the image picker, puts in your imagePickerView
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // two of two optional methods from UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        
        // dismisses the image picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Move the view up/down when the keyboard pops up over lower text field
    func keyboardWillShow(notification: NSNotification) {
        
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    // hides keyboard from notification
    func keyboardWillHide(notification: NSNotification) {
            view.frame.origin.y = 0.0
    }
    
    // configures keyboard hide, so can move view that amount
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MemeMainViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }

    // when press return in text field, keyboard dismisses
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    // Calls this function when the tap on background is recognized.
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // picks image from camera
    @IBAction func pickImage(sender: AnyObject) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
    }
    
    // picks a photo from photo album
    @IBAction func pickAnImageFromAlbum (sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
        // enable the share button, since you have a meme now
        shareBarButton.enabled = true
        
    }
    
    // CREATE MEME OBJECT, SAVE IT
    // Create a UIImage that combines the Image View and the Textfields
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        navigationController?.navigationBarHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        
        // render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar, again
        navigationController?.navigationBarHidden = false
        navigationController?.setToolbarHidden(false, animated: false)
        
        
        return memedImage
    }
    
    // saves the new meme
    func saveMeme() -> Meme{
        // Create the meme, by using the struct variables
        memeObject = Meme(textField1: topTextField.text!, textField2: bottomTextField.text!, image: imageView.image!, memedImage: generateMemedImage())
        
        return memeObject!
    }
    
    // share the meme method
    @IBAction func shareMeme(sender: AnyObject) {
        
        // instantiate activity view controller
        let activityViewController = UIActivityViewController.init(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender as? UIView
        // present the view controller
        presentViewController(activityViewController, animated: true, completion: nil)
        // save it in the completionWithItemsHandler closure
        activityViewController.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
            
            // Return if cancelled
            if (!completed) {
                return
            }
            
            //activity complete
            self.saveMeme()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // unsubscribes from the keyboard notification when app disappears
        unsubscribeFromKeyboardNotifications()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
    }

}

