//
//  DetailViewController.swift
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import AVFoundation
import UIKit
import CoreBluetooth

let notificationKey = "reloadMasterView"

class DetailViewController: UIViewController, FlipViewControllerDelegate, GSViewControllerDelegate, HaoFlipViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, CBPeripheralManagerDelegate {
    
    
    @IBOutlet weak var save: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var studentImg: UIImageView!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var program: UITextField!
    @IBOutlet weak var interest: UITextField!
    @IBOutlet weak var countryAndState: UITextField!
    @IBOutlet weak var programmingLanguage: UITextField!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var projectIdea: UITextField!
    @IBOutlet weak var jobExperience: UITextField!
    @IBOutlet weak var rating: UITextField!
    
    @IBOutlet weak var changeImage: UIButton!
    
    //Data Sent View
    @IBOutlet weak var totalSize: UITextView! //data shown here
    @IBOutlet weak var totalView: UITextView!
    
    
    
    var dataEdited: Bool = false
    var tempStudent = Info()
    var hasPressedSave: Bool = false
    
    var group: String!
    var ratingData: Int = -1

    var audioPlayer: AVAudioPlayer!
    
    //Bluetooth
    @IBOutlet weak var advertisingSwitch: UISwitch!
    var peripheralManager:CBPeripheralManager!
    var transferCharacteristic:CBMutableCharacteristic!
    var dataToSend:NSData!
    var sendDataIndex:Int = 0
    var sendingEOM:Bool = false
    var sendingSIM:Bool = false
    
    
    var detailItem: Info? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    @IBAction func save(sender: AnyObject?) {
        self.tempStudent.name = self.studentName.text
        self.tempStudent.gender = self.gender.text
        self.tempStudent.program = self.program.text
        self.tempStudent.interest = self.interest.text
        self.tempStudent.countryAndState = self.countryAndState.text
        self.tempStudent.programmingLanguage = self.programmingLanguage.text
        self.tempStudent.groupName = self.groupName.text
        self.tempStudent.projectName = self.projectName.text
        self.tempStudent.projectIdea = self.projectIdea.text
        self.tempStudent.jobExperience = self.jobExperience.text
        self.tempStudent.image = self.studentImg.image
        self.tempStudent.completed = true
        changeStudentInFolder(self.detailItem!, tempStudent)
        changeStudentInGroupAndStudentList(self.detailItem!, tempStudent)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey, object: self)
        hasPressedSave = true
        
        self.detailItem!.name = self.studentName.text
        self.detailItem!.gender = self.gender.text
        self.detailItem!.program = self.program.text
        self.detailItem!.interest = self.interest.text
        self.detailItem!.countryAndState = self.countryAndState.text
        self.detailItem!.programmingLanguage = self.programmingLanguage.text
        self.detailItem!.groupName = self.groupName.text
        self.detailItem!.projectName = self.projectName.text
        self.detailItem!.projectIdea = self.projectIdea.text
        self.detailItem!.jobExperience = self.jobExperience.text
        self.detailItem!.image = self.studentImg.image
        self.detailItem!.completed = true
        
        let alertController = UIAlertController(title: "Save Confirmation", message:
            "You have saved new information", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.studentImg.image = image
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    @IBAction func showActionSheetTapped() {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Add Photo", message: "Please choose an option!", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let takePictureAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .Default) { action -> Void in
            //Code for launching the camera goes here
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(takePictureAction)
        //Create and add a second option action
        let choosePictureAction: UIAlertAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            //Code for picking from camera roll goes here
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                var imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(choosePictureAction)
        
        //We need to provide a popover sourceView when using it on iPad
        // actionSheetController.popoverPresentationController?.sourceView =  UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: Info = self.detailItem {
          //            if let label = self.detailDescriptionLabel {
            if self.studentName != nil {
                self.studentName.text = detail.name
                self.studentName.font = UIFont(name: "Avenir", size: 16)
            }
            if self.gender != nil {
                self.gender.text = detail.gender
                self.gender.font = UIFont(name: "Avenir", size: 16)
            }
            if self.program != nil {
                self.program.text = detail.program
                self.program.font = UIFont(name: "Avenir", size: 16)
            }
            if self.interest != nil {
                self.interest.text = detail.interest
                self.interest.font = UIFont(name: "Avenir", size: 16)
            }
            if self.countryAndState != nil {
                self.countryAndState.text = detail.countryAndState
                self.countryAndState.font = UIFont(name: "Avenir", size: 16)
            }
            if self.programmingLanguage != nil {
                self.programmingLanguage.text = detail.programmingLanguage
                self.programmingLanguage.font = UIFont(name: "Avenir", size: 16)
            }
            if self.groupName != nil {
                self.groupName.text = detail.groupName
                self.groupName.font = UIFont(name: "Avenir", size: 16)
            }
            if self.projectName != nil {
                self.projectName.text = detail.projectName
                self.projectName.font = UIFont(name: "Avenir", size: 16)
            }
            if self.projectIdea != nil {
                self.projectIdea.text = detail.projectIdea
                self.projectIdea.font = UIFont(name: "Avenir", size: 16)
            }
            if self.jobExperience != nil {
                self.jobExperience.text = detail.jobExperience
                self.jobExperience.font = UIFont(name: "Avenir", size: 16)
            }
            if self.studentImg != nil {
                self.studentImg.image = detail.image
            }
            if self.rating != nil {
                if detail.rating == -1 {
                    self.rating.text = "Not be rated"
                }
                else {
                    self.rating.text = "\(detail.rating)"
                }
                self.rating.font = UIFont(name: "Avenir", size: 16)
            }

            let student = self.detailItem
            group = student!.groupName
            
        }
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.scrollView.contentSize.height = 1000
        self.configureView()
        playBgMusic()
        
        //add Flip Button
        if self.detailItem != nil {
            let detail: Info = self.detailItem!
            var studentName = detail.name
            if (studentName == "Deyu Jiao" || studentName == "Guoshan Liu" || studentName == "Hao Wu"){
                var flipButton = UIBarButtonItem(title: "Flip", style: .Plain, target: self,    action:"showFlips:")
                self.navigationItem.rightBarButtonItem = flipButton
            }
        }
        
        self.totalSize.hidden = true
        self.totalView.hidden = true
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.peripheralManager.stopAdvertising()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*func findfilename() -> String! {
    let randomSong = Int(arc4random_uniform(5))
    
    switch randomSong {
    case 0: return "cartoon002"
    case 1: return "cartoon010"
    case 2: return "cartoon014"
    case 3: return "farm007"
    case 4: return "music001"
    default:
    break
    }
    return "cartoon002"
    }*/
    
    func playBgMusic() {
        /*let bgname = findfilename()
        let musicPath = NSBundle.mainBundle().pathForResource(bgname, ofType: "mp3")*/
        
        var musicPath = NSBundle.mainBundle().pathForResource("6365", ofType: "wav")
        if group == nil{
            return
        }
        if(group == "WJL") {
            musicPath = NSBundle.mainBundle().pathForResource("6365", ofType: "wav")
        } else if(group == "Si! Mas!"){
            musicPath = NSBundle.mainBundle().pathForResource("6249", ofType: "wav")
        }else if(group == "Hello World"){
            musicPath = NSBundle.mainBundle().pathForResource("applause10", ofType: "wav")
        }else if(group == "Apple Farm") {
            musicPath = NSBundle.mainBundle().pathForResource("dogbark2", ofType: "wav")
        }else if(group == "HelloSiri") {
            musicPath = NSBundle.mainBundle().pathForResource("cartoon002", ofType: "mp3")
        }else if(group == "Bug Free") {
            musicPath = NSBundle.mainBundle().pathForResource("cartoon010", ofType: "mp3")
        }else if(group == "Shooting Guards") {
            musicPath = NSBundle.mainBundle().pathForResource("cartoon014", ofType: "mp3")
        } else if (group == "Physaologists") {
            musicPath = NSBundle.mainBundle().pathForResource("cheer2", ofType: "wav")
        } else if(group == "9") {
            musicPath = NSBundle.mainBundle().pathForResource("farm007", ofType: "mp3")
        } else if(group == "10") {
            musicPath = NSBundle.mainBundle().pathForResource("musical001", ofType: "mp3")
        }
            
        else{
            musicPath = NSBundle.mainBundle().pathForResource("musical001", ofType: "mp3")
        }
        
        let url = NSURL(fileURLWithPath: musicPath!)
        
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: nil)
        
        audioPlayer.numberOfLoops = 0
        
        audioPlayer.volume = 1
        
        audioPlayer.prepareToPlay()
        
        audioPlayer.play()
    }
    
    
    //show flip views
    func showFlips(sender: UIBarButtonItem) {
        
        let detail: Info = self.detailItem!
        var studentName = detail.name
        if (studentName == "Hao Wu"){
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var vc: HaoFlipViewController = storyboard.instantiateViewControllerWithIdentifier("HaoView") as! HaoFlipViewController
            vc.data = "This is very important data!"
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        if (studentName == "Deyu Jiao"){
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var vc: FlipViewController = storyboard.instantiateViewControllerWithIdentifier("DeyuView") as! FlipViewController
            vc.data = "This is very important data!"
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        if (studentName == "Guoshan Liu"){
            var storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            var vc: GSViewController = storyboard.instantiateViewControllerWithIdentifier("GSView") as! GSViewController
            vc.data = "This is very important data!"
            vc.delegate = self
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    func acceptData(data:AnyObject!) {
        let dataString = data as! String
        let num = dataString.toInt()!
        let from: Info = self.detailItem!
        let to: Info = self.detailItem!
        to.rating = num
        changeStudentInFolder(from, to)
        changeStudentInGroupAndStudentList(from, to)
        NSNotificationCenter.defaultCenter().postNotificationName(notificationKey, object: self)
            if num == -1 {
                self.rating.text = "Not be rated"
            }
            else {
                self.rating.text = "\(num)"
            }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Peripheral Methods
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            return
        }
        else {
            println("powered on and ready to go")
            // This is an example of a Notify Characteristic for a Readable value
            transferCharacteristic = CBMutableCharacteristic(type:
                characteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            // This sets up the Service we will use, loads the Characteristic and then adds the Service to the Manager so we can start advertising
            var transferService = CBMutableService(type: serviceUUID, primary: true)
            transferService.characteristics = [self.transferCharacteristic]
            self.peripheralManager.addService(transferService)
            
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didSubscribeToCharacteristic characteristic: CBCharacteristic!) {
        println("data request connection coming in")
        // A subscriber was found, so send them the data
        //       self.dataToSend = self.detailItem!.name.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        self.dataToSend = NSKeyedArchiver.archivedDataWithRootObject(self.detailItem!)
        self.sendDataIndex = 0
        self.sendData()
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager!, central: CBCentral!, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic!) {
        println("unsubscribed")
    }
    
    func sendData() {
        if (sendingEOM) {                // sending the end of message indicator
            var didSend:Bool = self.peripheralManager.updateValue(endOfMessage, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
            if (didSend) {
                sendingEOM = false
                println("sent EOM, outer loop")
                self.totalSize.text = "Finished!"
            }
            else {
                return
            }
        }
        else if (sendingSIM){
            var didStop:Bool = self.peripheralManager.updateValue(stopInMiddle, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
            if (didStop){
                sendingSIM = false
                println("sent SIM")
                
            }
            else{
                return
            }
        }
        else {                          // sending the payload
            if (self.sendDataIndex >= self.dataToSend.length) {
                return
            }
            else {
                var didSend:Bool = true
                while (didSend) {
                    var amountToSend = self.dataToSend.length - self.sendDataIndex
                    if (amountToSend > MTU) {
                        amountToSend = MTU
                    }
                    let chunk = NSData(bytes: self.dataToSend.bytes+self.sendDataIndex, length: amountToSend)
                    
                    didSend = self.peripheralManager.updateValue(chunk, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
                    
                    if (!didSend) {
                        return
                    }
                    println("Sent ",NSString(data: chunk, encoding: NSUTF8StringEncoding))
                    self.sendDataIndex += amountToSend
                    if (self.sendDataIndex >= self.dataToSend.length) {
                        sendingEOM = true
                        let eomSent:Bool = self.peripheralManager.updateValue(endOfMessage, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
                        if (eomSent) {
                            sendingEOM = false
                            println("send EOM, inner loop")
                        }
                        return
                    }
                    if self.advertisingSwitch.on == false {
                        sendingSIM = true
                        let simSent:Bool = self.peripheralManager.updateValue(stopInMiddle, forCharacteristic: self.transferCharacteristic, onSubscribedCentrals: nil)
                        if (simSent) {
                            sendingSIM = false
                            println("send SIM, inner loop")
                        }
                        self.peripheralManager.stopAdvertising()
                        return
                    }
                    println("Total data size is \(self.dataToSend.length)")
                    println("Current sent size is \(self.sendDataIndex)")
                    self.totalSize.text = String(self.sendDataIndex) + " / " + String(self.dataToSend.length)
                    
                }
            }
        }
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager!) {
        self.sendData()
    }
    
    
    
    // MARK: - Switch Methods
    
    @IBAction func switchChanged(sender: AnyObject) {
        if (self.advertisingSwitch.on) {
            let dataToBeAdvertised: [String:AnyObject!] = [
                CBAdvertisementDataServiceUUIDsKey : serviceUUIDs ]
            self.peripheralManager.startAdvertising(dataToBeAdvertised)
            println("DetailView is broadcasting! Data is \(dataToBeAdvertised)")
            
            self.totalSize.hidden = false
            self.totalView.hidden = false
            
        }
        else {
            self.totalSize.hidden = true
            self.totalView.hidden = true
            self.totalSize.text = ""
        }
    }

    
    


    
}

