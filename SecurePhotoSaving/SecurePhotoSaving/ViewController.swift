//
//  ViewController.swift
//  SecurePhotoSaving
//
//  Created by SSD3 on 2/20/17.
//  Copyright © 2017 Codility. All rights reserved.
//

import UIKit
import AVFoundation

/*!
 * @discussion This class will save the 10 photos of user in keychain using secure encryption
 *
 *
 */
class ViewController: UIViewController,AVCapturePhotoCaptureDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    ///camera view for showing camera
    var cameraView:UIView = UIView(frame:CGRect(x: 0, y: 0, width: 0, height: 0));
    /// session for AVCapture
    let captureSession = AVCaptureSession()
    /// AVCapture ouptput
    var sessionOutput = AVCapturePhotoOutput()
    /// AVCapture Still Image Output
    let stillImageOutput = AVCaptureStillImageOutput()
    /// AVCapture Video Preview Layer
    var previewLayer = AVCaptureVideoPreviewLayer()
    /// AVCapture output settings
    var sessionOutputSetting = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecJPEG])
    /// Error
    var error: NSError?
    /// Timer for capturing 10 photos at interval of 0.5 seconds
    var timer = Timer()
    /// Counter for 10 photos
    var counter = 0
    /// Total number of photos to be saved in keychain
    var totalPhoto = 10;
    /// Keychain object to store photo in keychain
    let keychain = KeychainSwift()
    /// key for encrypting the photo stored in keychain
    let password = "com.unify.id.jignesh.ERIOPC@*$)@"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*!
     * @discussion This function is called when start button is pressed.It will check for the Permissions to open camera
     * @param AnyObject Button ID.
     * @return No Return
     */
    @IBAction func openCameraButton(sender: AnyObject) {
        
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied: break
        case .authorized:
            self.openCamera()
            break
        case .restricted: break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                    DispatchQueue.main.sync {
                        self.openCamera()
                    }
                    
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    
    /*!
     * @discussion This function is called when user press start button and has authorise to use the device camera. It will start the video using front camera and will also take photos at interval of 0.5 seconds.
     * @param No Param
     * @return No Return
     */
    func openCamera(){
        let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDuoCamera, AVCaptureDeviceType.builtInTelephotoCamera,AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
        for device in (deviceDiscoverySession?.devices)! {
            if (device as AnyObject).position == AVCaptureDevicePosition.front {
                do{
                    let input = try AVCaptureDeviceInput(device: device )
                    if captureSession.canAddInput(input){
                        captureSession.addInput(input)
                        
                        
                        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
                        if captureSession.canAddOutput(stillImageOutput){
                            captureSession.addOutput(stillImageOutput)
                            captureSession.sessionPreset = AVCaptureSessionPresetPhoto
                            
                            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                            cameraView = UIView(frame: CGRectMake(0.0, 0.0, view.bounds.size.width, view.bounds.size.height))
                            cameraView.layer.addSublayer(previewLayer)
                            previewLayer.frame = cameraView.bounds
                            captureSession.startRunning()
                            
                            
                            //                            cameraView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(ViewController.saveToCamera)))
                            
                            self.view.addSubview(cameraView)
                            
                            startTimer()
                            
                            
                            break;
                            
                        }
                    }
                }
                catch{
                    print("Error displaying camera data")
                }
            }
        }
        
    }
    
    
    
    /*!
     * @discussion This will start he timer for 0.5 seconds
     * @param No Param
     * @return No Return
     */
    func startTimer(){
        timer.invalidate() // just in case this button is tapped multiple times
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
    
    /*!
     * @discussion This function is called at every 0.5 seconds
     * @param No Param
     * @return No Return
     */
    func timerAction(){
        timer.invalidate() // just in case this button is tapped multiple times
        saveToKeyChain();
    }
    
    
    /*!
     * @discussion This function is called save the still image from video. This will encryp the image and store in keychain.
     * @param No Param
     * @return No Return
     */
    func saveToKeyChain() {
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                
                var key = "Photo"+String(self.counter);
                print("Photo saved with key " + key);
                let encrypData = RNCryptor.encrypt(data: imageData!, withPassword: self.password)
                self.keychain.set(encrypData, forKey: key)
                
                
                self.counter=self.counter+1;
                if(self.counter < self.totalPhoto){
                    self.startTimer()
                }else{
                    self.timer.invalidate() // just in case this button is tapped multiple times
                    
//                    self.testSavingOfPhotos()   // This line should be uncommented to save the photos in Photo Gallery.
                    
                    self.counter = 0;
                    
                    
                    var input:AVCaptureInput = self.captureSession.inputs[0] as! AVCaptureInput;
                    if(input != nil){
                        self.captureSession.removeInput((input));
                    }
                    
                    
                    var output:AVCaptureOutput = self.captureSession.outputs[0] as! AVCaptureOutput;
                    if(output != nil){
                        self.captureSession.removeOutput(output);
                    }
                    
                    self.captureSession.stopRunning()
                    self.previewLayer.removeFromSuperlayer()
                    self.cameraView.removeFromSuperview();
                    
                    
                }
                
            }
        }
        
        
        
    }
    
    
    
    /*!
     * @discussion This function is basically conversion from Objc style to Swift
     * @param No Param
     * @return No Return
     */
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    /*!
     * @discussion This function is called when views are changed or added
     * @param No Param
     * @return No Return
     */
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    /*!
     * @discussion This function is for testing purpose only. If user wants to see the saved photos from keychain.
     * @param No Param
     * @return No Return
     */
    func testSavingOfPhotos(){
        for var i in 0..<counter {
            var key = "Photo"+String(i);
            print("\nPhoto retrieved with key " + key);
            var imageData = keychain.getData(key);
            
            // Decryption
            do {
                let originalData = try RNCryptor.decrypt(data: imageData!, withPassword: self.password)
                
                
                //UIImageWriteToSavedPhotosAlbum(UIImage(data: originalData)!, nil, nil, nil);
                
                UIImageWriteToSavedPhotosAlbum(UIImage(data: originalData)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                
                // ...
            } catch {
                print(error)
            }
            
        }
    }
    
    /*!
     * @discussion This function is for testing purpose only. It will tell if any error in saving in photo album
     * @param No Param
     * @return No Return
     */
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            
        } else {
            
            
        }
    }
    
    
    
    
}



