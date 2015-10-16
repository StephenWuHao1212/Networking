import UIKit


class NewStudentViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate{
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var program: UITextField!
    @IBOutlet weak var interest: UITextField!
    @IBOutlet weak var countryAndState: UITextField!
    @IBOutlet weak var studentName: UITextField!
    @IBOutlet weak var programmingLanguage: UITextField!
    @IBOutlet weak var groupName: UITextField!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var projectIdea: UITextField!
    @IBOutlet weak var jobExperience: UITextField!
    
    
    @IBOutlet weak var imagePicked: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize.height = 1000
        
        self.gender.delegate = self
        self.program.delegate = self
        self.interest.delegate = self
        self.countryAndState.delegate = self
        self.studentName.delegate = self
        self.programmingLanguage.delegate = self
        self.groupName.delegate = self
        self.projectName.delegate = self
        self.projectIdea.delegate = self
        self.jobExperience.delegate = self
        
        self.studentName.text = "default"
        // Do any additional setup after loading the view.
    }
    
    var newStudent = Info()
    var studentIsValid: Bool = false
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if((sender as! UIBarButtonItem) != self.saveButton){
            return
        }
        if segue.identifier == "saveExit"{
            if self.studentName.text == "" || self.groupName.text == "" {
                let alertController = UIAlertController(title: "Message Input Error", message:
                    "Please input student name and corresponding group name", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                self.studentIsValid = false
            }
            else{
                self.newStudent.name = self.studentName.text
                self.newStudent.gender = self.gender.text
                self.newStudent.program = self.program.text
                self.newStudent.interest = self.interest.text
                self.newStudent.countryAndState = self.countryAndState.text
                self.newStudent.programmingLanguage = self.programmingLanguage.text
                self.newStudent.groupName = self.groupName.text
                self.newStudent.projectName = self.projectName.text
                self.newStudent.projectIdea = self.projectIdea.text
                self.newStudent.jobExperience = self.jobExperience.text
                self.newStudent.rating = -1
                
                self.newStudent.completed = false
                self.newStudent.image = self.imagePicked.image
                addStudentToFolder(self.newStudent)
                self.studentIsValid = true
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imagePicked.image = image
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
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
