//
//  HaoFlipViewController.swift
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit

protocol HaoFlipViewControllerDelegate : class {
    func acceptData(data:AnyObject!)
}


class HaoFlipViewController: UIViewController, SwiftPromptsProtocol {
    
    
    let racquet = UIImageView(image: UIImage(named: "racquet.jpg"))
    let racquet2 = UIImageView(image: UIImage(named: "racquet.jpg"))
    let ball = UIImageView()
    
    
    var prompt = SwiftPromptsView()
    var rateData : String = ""
    var data : AnyObject?
    weak var delegate : FlipViewControllerDelegate?
    
    
    @IBOutlet weak var back: UIButton!
    @IBAction func back(sender: UIButton!){
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
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.opaque = false
        self.view.addSubview(racquet)
        self.view.addSubview(racquet2)
        racquet.frame = CGRectMake(35, 80, 150, 150)
        racquet2.frame = CGRectMake(150, 400, 150, 150)
        
        var button: UIButton!

        button = UIButton.buttonWithType(.DetailDisclosure) as! UIButton
        button.backgroundColor = UIColor.clearColor()
        button.hidden = false
        button.setTitle("Run", forState: .Normal)
        button.frame = CGRectMake(170, 30, 200, 30)
        button.addTarget(self, action: "run:", forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        // Do any additional setup after loading the view.
    }
    
    func run(sender: UIButton!) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), false, 0)
        let p = UIBezierPath(ovalInRect: CGRectMake(0, 0, 30, 30))
        UIColor.yellowColor().setFill()
        let con = UIGraphicsGetCurrentContext()
        //setting up shadow
        CGContextSetShadow(con, CGSizeMake(7, 7), 12)
        p.fill()
        let im = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        ball.image = im
        self.view.addSubview(ball)
        var ballX:CGFloat = 120
        var ballY:CGFloat = 110
        var ballEndX: CGFloat = 240
        var ballEndY:CGFloat = 425
        ball.frame = CGRectMake(ballX, ballY, 30, 30)
        
        //Animation
        
        UIView.animateWithDuration(2, delay: 0.0, options: .Repeat | .Autoreverse,  animations: {
            self.ball.frame = CGRectMake(ballEndX, ballEndY, 30, 30)
            }, completion: nil)
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
