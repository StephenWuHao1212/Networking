//
//  myArt.swift
//  StudentInfo
//
//  Created by Guoshan Liu on 9/21/15.
//  Copyright (c) 2015 Guoshan Liu. All rights reserved.
//

import UIKit

protocol GSViewControllerDelegate : class {
    func acceptData(data:AnyObject!)
}

class GSViewController: UIViewController, SwiftPromptsProtocol {
    
    let iv = UIImageView(image:UIImage(named:"piano.png"))
    //let note = UIImageView(image: UIImage(named: "note.png"))
    let im = drawingView(frame: CGRectMake(150, 100, 100, 100))
    let cir = drawingView(frame: CGRectMake(200, 40, 200, 200))
    let enote = "\u{e03e}"
    
    var prompt = SwiftPromptsView()
    var rateData : String = ""
    var data : AnyObject?
    weak var delegate : FlipViewControllerDelegate?
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var fadePic: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "blue.png")!)
        self.view.addSubview(iv)
        iv.frame = CGRectMake(100, 250, 200, 150)
        //note.frame = CGRectMake(10, 20, 300, 150)
        
        
        
        self.view.addSubview(im)
        self.view.addSubview(cir)
        
        blurAndVibrancy()
        addShadows()
        fadePic.animationImages = [
            UIImage(named: "me1.png")!,
            UIImage(named: "me2.png")!,
            UIImage(named:"me3.png")!,
            UIImage(named: "keyboard.png")!
        ]
        fadePic.animationDuration = 5.0
        fadePic.startAnimating()
        
        
    }
    
    /*
    func initAppearance() {
    let background = CAGradientLayer().turquoiseColor()
    background.frame = self.view.bounds
    self.view.layer.insertSublayer(background, atIndex: 0)
    }*/
    //Other Topic: Shadows
    
    @IBAction func back(sender: UIButton){
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
    
    
    func addShadows() {
        iv.layer.shadowOffset = CGSize(width: 10, height: 10)
        iv.layer.shadowOpacity = 0.7
        iv.layer.shadowRadius = 3
        
    }
    
    
    //Other Topic: Blur and Vibrancy
    func blurAndVibrancy() {
        let extraLightBlur = UIBlurEffect(style: .ExtraLight)
        let extraLightBlurView = UIVisualEffectView(effect: extraLightBlur)
        extraLightBlurView.userInteractionEnabled = false
        self.view.addSubview(extraLightBlurView)
        
        let blurAreaAmount = self.view.bounds.height/5
        
        
        var remainder: CGRect
        (extraLightBlurView.frame, remainder) = self.view.bounds.rectsByDividing(blurAreaAmount, fromEdge:CGRectEdge.MaxYEdge)
        
        let extraLightVibrancyView = vibrancyEffectView(forBlurEffectView: extraLightBlurView)
        extraLightBlurView.contentView.addSubview(extraLightVibrancyView)
        
        let extraLightTitleLabel = titleLabel(text: "Music is Part of My Life!\u{e03e}")
        extraLightBlurView.contentView.addSubview(extraLightTitleLabel)
        
    }
    
    func vibrancyEffectView(forBlurEffectView blurEffectView: UIVisualEffectView) -> UIVisualEffectView {
        let vibrancy = UIVibrancyEffect(forBlurEffect: blurEffectView.effect as! UIBlurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.userInteractionEnabled = false
        vibrancyView.frame = blurEffectView.bounds
        vibrancyView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return vibrancyView
    }
    
    func titleLabel(#text: String)->UILabel {
        let label = UILabel()
        label.text = text
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 50, y: 40)
        return label
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
