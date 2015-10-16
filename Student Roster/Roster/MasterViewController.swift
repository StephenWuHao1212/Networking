//
//  MasterViewController.swift
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit
import CoreBluetooth


class MasterViewController: UITableViewController,UISearchResultsUpdating, CBCentralManagerDelegate, CBPeripheralDelegate{

    var detailViewController: DetailViewController? = nil
    var resultSearchController = UISearchController()
    
    //studentsList: store information of current students
    //groupList: store information of group and group members
    //groupNames: store information of group names
    
    //bluetooth
    var centralManager:CBCentralManager!
    var connectingPeripheral:CBPeripheral!
    var dataString:String = ""
    var mutableData = NSMutableData()
    var scanFlag:Bool = false
    var clickFlag:Bool = false
    
    @IBOutlet weak var receiveBluetooth: UIBarButtonItem!
    
    
    //unwind from new student addition view controller
    @IBAction func unwindToList(segue: UIStoryboardSegue){
        let source:NewStudentViewController = segue.sourceViewController as! NewStudentViewController
        if source.studentIsValid {
            let student:Info = source.newStudent
            addStudentToGroupAndStudentList(student)
        }
        self.tableView.reloadData()
    }
    
    @IBAction func receiveFromBluetooth(sender: UIBarButtonItem){
        if clickFlag == false{
            self.mutableData = NSMutableData()
        
            scanFlag = true
            centralManager = CBCentralManager(delegate: self, queue: nil)
            
        }
        clickFlag = true

    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }
        
    func loadDataFromStudents(){
        var students = Students()
        for student in students.students{
            addStudentToGroupAndStudentList(student)
            addStudentToFolder(student)
        }
    }
    
    func clearGroupList(){
        for key in groupList.keys{
            if key == "" {
                groupList[""] = nil
            }
        }
        for var i = 0; i < groupNames.count; i++ {
            if groupNames[i] == "" {
                groupNames.removeAtIndex(i)
            }
        }
    }
    
    func loadInitialData() {
        let fm = NSFileManager()
        var err:NSError?
        
        if let suppurl = fm.URLForDirectory( .ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true, error: &err){
            let appInfoURL = suppurl.URLByAppendingPathComponent("AppInfo")
            let dir = fm.enumeratorAtURL(appInfoURL, includingPropertiesForKeys: nil, options: nil, errorHandler: nil)!
            var dirIsEmpty = 1
            while let file = dir.nextObject() as? NSURL{
                if file.pathExtension == "txt" {
                    let studentData = NSData(contentsOfURL: file)!
                    if let student = NSKeyedUnarchiver.unarchiveObjectWithData(studentData) as? Info {
                        addStudentToGroupAndStudentList(student)
                        dirIsEmpty = 0
                    }
                }
            }
            if dirIsEmpty == 1{
                loadDataFromStudents()
            }
        }
        else{
                loadDataFromStudents()
        }
        clearGroupList()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
        }
        
        loadInitialData()
        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            self.tableView.tableHeaderView = controller.searchBar
            return controller
        })()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "actOnNotification", name: notificationKey, object: nil)
        self.tableView.reloadData()
        
    }
 
    override func viewWillDisappear(animated: Bool) {
        if (scanFlag){
            self.centralManager.stopScan()
            println("scanning stopped")
        }
        super.viewWillDisappear(animated)
    }

    func actOnNotification() {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            var object = Info()
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                if self.resultSearchController.active{
                    object = filteredGroupList[filteredGroupNames[indexPath.section]]![indexPath.row]
                }
                else{
                    object = groupList[groupNames[indexPath.section]]![indexPath.row]
                }
            }
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.resultSearchController.active{
            return filteredGroupNames.count
        }
        else{
            println(groupList.count)
            return groupNames.count
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active{
            return filteredGroupList[filteredGroupNames[section]]!.count
        }
        else{
            return groupList[groupNames[section]]!.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        
        cell.textLabel!.backgroundColor = UIColor.clearColor()
        cell.textLabel!.font = UIFont (name:"Avenir", size:22)
        
        var tempStudent: Info
        
        if self.resultSearchController.active{
            tempStudent = filteredGroupList[filteredGroupNames[indexPath.section]]![indexPath.row]
        }
        else{
            tempStudent = groupList[groupNames[indexPath.section]]![indexPath.row]
        }
        
        var name = tempStudent.name
        
        cell.textLabel?.text = name
        
        cell.imageView!.image = tempStudent.image
        if name == "Guoshan Liu" || name == "Hao Wu" || name == "Deyu Jiao" {
            cell.textLabel?.textColor = UIColor.blueColor()
        }else {
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        
        if tempStudent.completed == true{
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
    
        return cell
        

    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true

    }
    
    func initStudentImages(student:Info){
        var err: NSError?
        let fm = NSFileManager()
        if let suppurl = fm.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err){
            let appInfo = suppurl.URLByAppendingPathComponent("AppInfo")
            
            let image = UIImage(named: student.name + ".jpg")
            if image != nil {
                let imageURL = appInfo.URLByAppendingPathComponent(student.name + ".jpg")
                UIImageJPEGRepresentation(image, 1.0).writeToURL(imageURL, atomically: true)
            }
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let removedStudent:Info  = groupList[groupNames[indexPath.section]]![indexPath.row]
            groupList[groupNames[indexPath.section]]!.removeAtIndex(indexPath.row)
            if groupList[groupNames[indexPath.section]]!.isEmpty {
                groupList[groupNames[indexPath.section]] = nil
                groupNames.removeAtIndex(indexPath.section)
                for var i = 0; i < studentsList.count; i++ {
                    if removedStudent.name == studentsList[i].name {
                        studentsList.removeAtIndex(i)
                        break
                    }
                }
            }
            deleteStudentFromFolder(removedStudent)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.resultSearchController.active{
            return filteredGroupNames[section]
        }
        else{
            return groupNames[section]
        }
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view:UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView //recast your view as a UITableViewHeaderFooterView
        header.contentView.backgroundColor = UIColor(red: 0/255, green: 181/255, blue: 229/255, alpha: 1.0) //make the background color light blue
        header.textLabel.textColor = UIColor.whiteColor() //make the text white
        header.alpha = 0.5 //make the header transparent
    }

    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        filteredInfo.removeAll(keepCapacity: false)
        if(!filteredGroupList.isEmpty){
            filteredGroupList.removeAll(keepCapacity: false)
        }
        if(!filteredGroupNames.isEmpty){
            filteredGroupNames.removeAll(keepCapacity: false)
        }
        
        let searchPredicate = NSPredicate(format: "self.name contains[c] %@", searchController.searchBar.text)
        let array = (studentsList as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredInfo = array as! [Info]
        
        for student in filteredInfo{
            if filteredGroupList[student.groupName] == nil{
                filteredGroupList[student.groupName] = [student]
                filteredGroupNames.append(student.groupName)
            }
            else{
                filteredGroupList[student.groupName]?.append(student)
            }
        }
        self.tableView.reloadData()
        
    }
    

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let student:Info  = groupList[groupNames[indexPath.section]]![indexPath.row]
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
            groupList[groupNames[indexPath.section]]!.removeAtIndex(indexPath.row)
            if groupList[groupNames[indexPath.section]]!.isEmpty {
                groupList[groupNames[indexPath.section]] = nil
                groupNames.removeAtIndex(indexPath.section)
                for var i = 0; i < studentsList.count; i++ {
                    if student.name == studentsList[i].name {
                        studentsList.removeAtIndex(i)
                        break
                    }
                }
            }
            deleteStudentFromFolder(student)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        delete.backgroundColor = UIColor.orangeColor()

        let email = UITableViewRowAction(style: .Normal, title: "Email") { action, index in
            var nameArr = split(student.name) {$0 == " "}
            var firstName: String = nameArr[0]
            var lastName: String = nameArr[1]

            let email = firstName + "." + lastName + "@duke.edu"
            
            let url = NSURL(string: "mailto:\(email)")
            UIApplication.sharedApplication().openURL(url!)
        }
        email.backgroundColor = UIColor.blueColor()
        
        return [email, delete]
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tempStudent:Info
        if self.resultSearchController.active{
            tempStudent = filteredGroupList[filteredGroupNames[indexPath.section]]![indexPath.row]
        }
        else{
            tempStudent = groupList[groupNames[indexPath.section]]![indexPath.row]
        }
        
        if tempStudent.completed == false{
            tempStudent.completed = !tempStudent.completed
            addStudentToFolder(tempStudent)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
        //        self.performSegueWithIdentifier("studentInfoSegue", sender: tableView)
    }
    
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount: Int
        if self.resultSearchController.active{
            itemCount = filteredGroupNames.count
        }
        else{
            itemCount = groupNames.count
        }
        
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.section*3 + indexPath.row)
    }
    
    // MARK:  Central Manager Delegate methods
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        println("checking state")
        switch(central.state) {
        case .PoweredOff:
            println("CB BLE hw is powered off")
            
        case .PoweredOn:
            println("CB BLE hw is powered on")
            self.scan()
            
        default:
            return
        }
    }
    
    func scan() {
        self.centralManager.scanForPeripheralsWithServices(serviceUUIDs,options: nil)
        println("scanning started\n\n\n")
    }
    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        if RSSI.integerValue > -15 {
            return
        }
        println("discovered \(peripheral.name) at \(RSSI)")
        if connectingPeripheral != peripheral {
            connectingPeripheral = peripheral
            connectingPeripheral.delegate = self
            println("connecting to peripheral \(peripheral)")
            centralManager.connectPeripheral(connectingPeripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager!, didFailToConnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("failed to connect to \(peripheral) due to error \(error)")
        self.cleanup()
    }
    
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        println("\n\nperipheral connected\n\n")
        centralManager.stopScan()
        peripheral.delegate = self as CBPeripheralDelegate
        peripheral.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        if let actualerror = error {
            println("error discovering services \(error.description)")
            self.cleanup()
        }
        else {
            for service in peripheral.services as! [CBService] {
                println("service UUID  \(service.UUID)\n")
                if (service.UUID == serviceUUID) {
                    peripheral.discoverCharacteristics(nil, forService: service)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        if let actualerror = error {
            println("error - \(error.description)")
            println(error)
            self.cleanup()
        }
        else {
            for characteristic in service.characteristics as! [CBCharacteristic] {
                println("characteristic is \(characteristic)\n")
                if (characteristic.UUID == characteristicUUID) {
                    peripheral.setNotifyValue(true, forCharacteristic: characteristic)
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let actualerror = error {
            println("error")
        }
        else {
            let dataString = NSString(data: characteristic.value, encoding: NSUTF8StringEncoding)
            if dataString == "EOM" {
                //                println(self.data)
                let dataStudent = NSKeyedUnarchiver.unarchiveObjectWithData(self.mutableData) as! Info
                println("MatserView got the data!!!!!!!!!!!\(dataStudent.name)")
                
                showActionSheetTapped(dataStudent) // Do sth with the received data by action sheet
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                centralManager.cancelPeripheralConnection(peripheral)
                self.mutableData = NSMutableData()  //clear the mutabledata
                self.clickFlag = false
            }
            else if dataString == "SIM"{
                peripheral.setNotifyValue(false, forCharacteristic: characteristic)
                centralManager.cancelPeripheralConnection(peripheral)
                self.mutableData = NSMutableData()  //clear the mutabledata
                self.clickFlag = false
            }
            else {
                var getData: NSData = characteristic.value
                self.mutableData.appendData(getData)
                
                println("received mutableData")
            }
            
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        if let actualerror = error {
            println("error changing notification state \(error.description)")
        }
        if (characteristic.UUID != serviceUUID) {
            return
        }
        if (characteristic.isNotifying) {
            println("notification began on \(characteristic)")
        }
        else {
            println("notification stopped on \(characteristic). Disconnecting")
            self.centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("didDisconnect error is \(error)")
    }
    
    func cleanup() {
        
        switch connectingPeripheral.state {
        case .Disconnected:
            println("cleanup called, .Disconnected")
            return
        case .Connected:
            if (connectingPeripheral.services != nil) {
                println("found")
                //add any additional cleanup code here
            }
        default:
            return
        }
    }

    func showActionSheetTapped(student: Info) {
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Received Confirmation", message: "Please choose an option!", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
            self.mutableData = NSMutableData()
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let confirmAction: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action -> Void in
            //Code for adding received data
            changeStudentInGroupAndStudentList(student, student)
            changeStudentInFolder(student, student)
            self.tableView.reloadData()
        }
        actionSheetController.addAction(confirmAction)
        //Create and add a second option action
        
        //We need to provide a popover sourceView when using it on iPad
        // actionSheetController.popoverPresentationController?.sourceView =  UIView;
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }


}

