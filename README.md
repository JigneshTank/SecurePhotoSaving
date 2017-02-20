# SecurePhotoSaving
This will securely save the 10 photos of user in iOS device. Keychain is used to save the photos.


About:
—> This application will start the front camera and will take 10 photos at interval of 0.5 seconds. Sounds will ensure that photo are being taken.
—> This photo is encrypted with key
—> Encrypted photo is stored in keychain
—> Application is written in Swift 3.0 and developed using Xcode 8.0


Compilation and Installation:
—> Please go to Targets -> Build Settings and search for Objective-C Bridging Header. In its value, put the complete path for RNCryptor.h. In my case, it was /Users/ssd3/Desktop/Jignesh/SecurePhotoSaving/RNCryptor.h

PS: If complete path is not entered in Objective-C Bridging Header, it will show many errors and application will not compile.

—> Change the code signing provisioning profile and install on your device.
