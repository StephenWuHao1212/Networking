//
//  FlipViewController.swift
//  ECE 590-06 Roster 2015
//
//  Created by Deyu Jiao on 9/21/15.
//  Copyright (c) 2015 Deyu Jiao. All rights reserved.
//

//Deyu's Flip View
import UIKit

protocol FlipViewControllerDelegate : class {
    func acceptData(data:AnyObject!)
}

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat, flip: Bool) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPointZero, size: size))
        let t = CGAffineTransformMakeRotation(degreesToRadians(degrees));
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        CGContextScaleCTM(bitmap, yFlip, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


class FlipViewController: UIViewController, SwiftPromptsProtocol {
    
    let iv = UIImageView(image: UIImage(named:"CHOIR.gif"))
    let iflower = UIImageView(image: UIImage(named:"sunflower.jpg"))
    let isun = UIImageView(frame: CGRectMake(300, 340, 100, 100))
    let notes = UIImageView(image: UIImage(named: "notes.png"))
    var buttonView: UIButton!
    var buttonPressed = 0
    var prompt = SwiftPromptsView()
    var rateData : String = ""
    
    var data : AnyObject?
    weak var delegate : FlipViewControllerDelegate?
    
    @IBOutlet weak var back: UIBarButtonItem!
    
    @IBOutlet weak var singButton: UIButton!
    
    @IBAction func refresh(sender: AnyObject) {
        
        rotateOnce()
    }
    
    @IBAction func back(sender: UIBarButtonItem){
        rateView()
    }
    
    
    
    func rateView(){
        //rating prompt
        //Create an instance of SwiftPromptsView and assign its delegate
        prompt = SwiftPromptsView(frame: self.view.bounds)
        prompt.delegate = self
        
        //Set the properties for the background
        prompt.setBlurringLevel(2.0)
        prompt.setColorWithTransparency(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.64))
        
        //Set the properties of the prompt
        prompt.setPromptHeader("Rate Now!")
        prompt.setPromptTopBarVisibility(true)
        prompt.setPromptBottomBarVisibility(false)
        prompt.setPromptTopLineVisibility(false)
        prompt.setPromptBottomLineVisibility(true)
        prompt.setPromptHeaderBarColor(UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 0.67))
        prompt.setPromptHeaderTxtColor(UIColor.whiteColor())
        prompt.setPromptContentTxtColor(UIColor(red: 59.0/255.0, green: 89.0/255.0, blue: 152.0/255.0, alpha: 0.72))
        prompt.setPromptBottomLineColor(UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0))
        prompt.enableDoubleButtonsOnPrompt()
        
        self.view.addSubview(prompt)
    }
    
    func rotateOnce(){
        UIView.animateWithDuration(5.0, delay: 1.0, options: .CurveLinear, animations: {
            self.notes.image = self.notes.image?.imageRotatedByDegrees(90, flip: false)
            
            }, completion:
            {finished in self.rotateAgain()}
        )
    }
    
    func rotateAgain(){
        UIView.animateWithDuration(5.0, delay: 1.0, options: .CurveLinear, animations: {
            self.notes.image = self.notes.image?.imageRotatedByDegrees(90, flip: false)
            
            }, completion:
            {finished in self.rotateOnce()}
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubview(iv)
        iv.frame = CGRectMake(45, 390, 230, 130)
        
        
        notes.frame = CGRectMake(60, 160, 200, 200)
        self.view.addSubview(self.notes)
        self.view.addSubview(iflower)
        iflower.frame = CGRectMake(110, 200, 100, 130)
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(100, 100), false, 0)
        let p = UIBezierPath(ovalInRect: CGRectMake(0, 0, 100, 100))
        UIColor.redColor().setFill()
        p.fill()
        let im = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        isun.image = im
        
        
        buttonView = UIButton()
        buttonView.backgroundColor = UIColor.orangeColor()
        buttonView.layer.borderColor = UIColor.blackColor().CGColor
        buttonView.layer.borderWidth = 2
        buttonView.hidden = false
        buttonView.frame = CGRectMake(142, 229, 36, 36)
        buttonView.layer.cornerRadius = 0.5 * buttonView.bounds.size.width
        buttonView.addTarget(self, action: "pressed:", forControlEvents: .TouchUpInside)
        buttonView.setTitle("十", forState: .Normal)
        buttonView.setTitleColor(UIColor.blackColor(), forState: .Normal)
        buttonView.setTitleColor(UIColor.grayColor(), forState: .Selected)
        buttonView.setTitleColor(UIColor.redColor(), forState: .Highlighted)
        buttonView.titleLabel!.font =  UIFont(name: "HelveticaNeue-Thin", size:30)
        buttonView.showsTouchWhenHighlighted = true
        buttonView.adjustsImageWhenDisabled = true
        buttonView.adjustsImageWhenHighlighted = true
        
        self.view.addSubview(buttonView)
        
        
    }
    
    func clickedOnTheMainButton() {
        println("Clicked on the main button")
        self.rateData = "1"
        prompt.dismissPrompt()
    }
    
    func clickedOnTheSecondButton() {
        println("Clicked on the second button")
        self.rateData = "2"
        prompt.dismissPrompt()
    }
    
    func clickedOnTheThirdButton() {
        println("Clicked on the third button")
        self.rateData = "3"
        prompt.dismissPrompt()
    }
    
    func clickedOnTheFourthButton() {
        println("Clicked on the fourth button")
        self.rateData = "4"
        prompt.dismissPrompt()
    }
    
    func clickedOnTheFifthButton() {
        println("Clicked on the fifth button")
        self.rateData = "5"
        prompt.dismissPrompt()
    }
    
    func promptWasDismissed() {
        println("Dismissed the prompt")
        //            println(self.rateData)
        self.presentingViewController!.dismissViewControllerAnimated(
            true, completion: nil)
        self.delegate?.acceptData(rateData)
    }
    
    func pressed(sender: UIButton!){
        buttonPressed++
        //        let iellipseLeft = EllipseLeft()
        switch buttonPressed {
        case 1:
            //     notes.image = notes.image?.imageRotatedByDegrees(90, flip: false)
            //     self.view.addSubview(notes)
            isun.frame = CGRectMake(35, 170, 50, 50)
            self.view.addSubview(isun)
            self.view.addSubview(iflower)
            self.view.addSubview(buttonView)
            
        case 2:
            isun.removeFromSuperview()
            //      notes.removeFromSuperview()
            iflower.removeFromSuperview()
            buttonView.removeFromSuperview()
            //      notes.image = notes.image?.imageRotatedByDegrees(180, flip: false)
            //      self.view.addSubview(notes)
            isun.frame = CGRectMake(135, 100, 50, 50)
            self.view.addSubview(isun)
            self.view.addSubview(iflower)
            self.view.addSubview(buttonView)
            
        case 3:
            isun.removeFromSuperview()
            
            //     notes.removeFromSuperview()
            iflower.removeFromSuperview()
            buttonView.removeFromSuperview()
            //     notes.image = notes.image?.imageRotatedByDegrees(270, flip: false)
            //     self.view.addSubview(notes)
            isun.frame = CGRectMake(235, 170, 50, 50)
            self.view.addSubview(isun)
            self.view.addSubview(iflower)
            self.view.addSubview(buttonView)
        default:
            isun.removeFromSuperview()
            buttonPressed = 0
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
