//
//  SwiftPromptsView.swift
//  Roster
//
//  Created by Deyu Jiao on 9/21/15.
//  Copyright (c) 2015 Deyu Jiao. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SwiftPromptsProtocol
{
    optional func clickedOnTheMainButton()
    optional func clickedOnTheSecondButton()
    optional func clickedOnTheThirdButton()
    optional func clickedOnTheFourthButton()
    optional func clickedOnTheFifthButton()
    optional func promptWasDismissed()
}

public class SwiftPromptsView: UIView
{
    //Delegate var
    public var delegate : SwiftPromptsProtocol?
    
    //Variables for the background view
    private var blurringLevel : CGFloat = 5.0
    private var colorWithTransparency = UIColor(red: 255.0, green: 255.0, blue: 255.0, alpha: 0.64)
    private var enableBlurring : Bool = true
    private var enableTransparencyWithColor : Bool = true
    
    //Variables for the prompt with their default values
    private var promptHeight : CGFloat = 197.0
    private var promptWidth : CGFloat = 225.0
    private var promptHeader : String = "Success"
    private var promptHeaderTxtSize : CGFloat = 20.0
    private var promptContentText : String = "Rate this student based on his/her drawing!"
    private var promptContentTxtSize : CGFloat = 18.0
    private var promptTopBarVisibility : Bool = false
    private var promptBottomBarVisibility : Bool = true
    private var promptTopLineVisibility : Bool = true
    private var promptBottomLineVisibility : Bool = false
    private var promptOutlineVisibility : Bool = false
    private var promptButtonDividerVisibility : Bool = false
    private var promptDismissIconVisibility : Bool = false
    
    
    //Colors of the items within the prompt
    private var promptBackgroundColor : UIColor = UIColor.whiteColor()
    private var promptHeaderBarColor : UIColor = UIColor.clearColor()
    private var promptBottomBarColor : UIColor = UIColor(red: 34.0/255.0, green: 192.0/255.0, blue: 100.0/255.0, alpha: 1.0)
    private var promptHeaderTxtColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptContentTxtColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptOutlineColor : UIColor = UIColor.clearColor()
    private var promptTopLineColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptBottomLineColor : UIColor = UIColor.clearColor()
    private var promptButtonDividerColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var promptDismissIconColor : UIColor = UIColor.whiteColor()
    
    //Button panel vars
    private var enableDoubleButtons : Bool = false
    private var mainButtonText : String = "1"
    private var secondButtonText : String = "2"
    private var thirdButtonText : String = "3"
    private var fourthButtonText : String = "4"
    private var fifthButtonText : String = "5"
    private var mainButtonColor : UIColor = UIColor(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    private var secondButtonColor : UIColor = UIColor(red: 170.0/255.0, green: 135.0/255.0, blue: 135.0/255.0, alpha: 1.0)
    private var thirdButtonColor : UIColor = UIColor(red: 185.0/255.0, green: 115.0/255.0, blue: 115.0/255.0, alpha: 1.0)
    private var fourthButtonColor : UIColor = UIColor(red: 200.0/255.0, green: 95.0/255.0, blue: 95.0/255.0, alpha: 1.0)
    private var fifthButtonColor : UIColor = UIColor(red: 215.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    
    //Gesture enabling
    private var enablePromptGestures : Bool = true
    
    //Declare the enum for use in the construction of the background switch
    enum TypeOfBackground
    {
        case LeveledBlurredWithTransparencyView
        case LightBlurredEffect
        case ExtraLightBlurredEffect
        case DarkBlurredEffect
    }
    private var backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView
    
    //Construct the prompt by overriding the view's drawRect
    override public func drawRect(rect: CGRect)
    {
        var backgroundImage : UIImage = snapshot(self.superview)
        var effectImage : UIImage!
        var transparencyAndColorImageView : UIImageView!
        
        //Construct the prompt's background
        switch backgroundType
        {
        case .LeveledBlurredWithTransparencyView:
            if (enableBlurring) {
                effectImage = backgroundImage.applyBlurWithRadius(blurringLevel, tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
                var blurredImageView = UIImageView(image: effectImage)
                self.addSubview(blurredImageView)
            }
            if (enableTransparencyWithColor) {
                transparencyAndColorImageView = UIImageView(frame: self.bounds)
                transparencyAndColorImageView.backgroundColor = colorWithTransparency;
                self.addSubview(transparencyAndColorImageView)
            }
        case .LightBlurredEffect:
            effectImage = backgroundImage.applyLightEffect()
            var lightEffectImageView = UIImageView(image: effectImage)
            self.addSubview(lightEffectImageView)
            
        case .ExtraLightBlurredEffect:
            effectImage = backgroundImage.applyExtraLightEffect()
            var extraLightEffectImageView = UIImageView(image: effectImage)
            self.addSubview(extraLightEffectImageView)
            
        case .DarkBlurredEffect:
            effectImage = backgroundImage.applyDarkEffect()
            var darkEffectImageView = UIImageView(image: effectImage)
            self.addSubview(darkEffectImageView)
        }
        
        //Create the prompt and assign its size and position
        var promptSize = CGRect(x: 0, y: 0, width: promptWidth, height: promptHeight)
        var swiftPrompt = PromptBoxView(master: self)
        swiftPrompt.backgroundColor = UIColor.clearColor()
        swiftPrompt.center = CGPointMake(self.center.x, self.center.y)
        self.addSubview(swiftPrompt)
        
        //Add the button(s) on the bottom of the prompt
        if (enableDoubleButtons == false)
        {
            let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.frame = CGRectMake(0, promptHeight-52, promptWidth, 41)
            button.setTitleColor(mainButtonColor, forState: .Normal)
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            button.setTitle(mainButtonText, forState: UIControlState.Normal)
            button.tag = 1
            button.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(button)
        }
        else
        {
            if (promptButtonDividerVisibility) {
                var divider = UIView(frame: CGRectMake(promptWidth/3, promptHeight-47, 0.5, 31))
                divider.backgroundColor = promptButtonDividerColor
                
                var divider2 = UIView(frame: CGRectMake(promptWidth*2/3, promptHeight-47, 0.5, 31))
                divider.backgroundColor = promptButtonDividerColor
                
                swiftPrompt.addSubview(divider2)
                swiftPrompt.addSubview(divider)
            }
            
            let button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            button.frame = CGRectMake(0, promptHeight-52, promptWidth/5, 41)
            button.setTitleColor(mainButtonColor, forState: .Normal)
            button.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            button.setTitle(mainButtonText, forState: UIControlState.Normal)
            button.tag = 1
            button.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(button)
            
            let secondButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            secondButton.frame = CGRectMake(promptWidth/5, promptHeight-52, promptWidth/5, 41)
            secondButton.setTitleColor(secondButtonColor, forState: .Normal)
            secondButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            secondButton.setTitle(secondButtonText, forState: UIControlState.Normal)
            secondButton.tag = 2
            secondButton.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(secondButton)
            
            let thirdButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            thirdButton.frame = CGRectMake(promptWidth*2/5, promptHeight-52, promptWidth/5, 41)
            thirdButton.setTitleColor(thirdButtonColor, forState: .Normal)
            thirdButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            thirdButton.setTitle(thirdButtonText, forState: UIControlState.Normal)
            thirdButton.tag = 3
            thirdButton.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(thirdButton)
            
            let fourthButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            fourthButton.frame = CGRectMake(promptWidth*3/5, promptHeight-52, promptWidth/5, 41)
            fourthButton.setTitleColor(fourthButtonColor, forState: .Normal)
            fourthButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            fourthButton.setTitle(fourthButtonText, forState: UIControlState.Normal)
            fourthButton.tag = 4
            fourthButton.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(fourthButton)
            
            let fifthButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            fifthButton.frame = CGRectMake(promptWidth*4/5, promptHeight-52, promptWidth/5, 41)
            fifthButton.setTitleColor(fifthButtonColor, forState: .Normal)
            fifthButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Light", size: 20)
            fifthButton.setTitle(fifthButtonText, forState: UIControlState.Normal)
            fifthButton.tag = 5
            fifthButton.addTarget(self, action: "panelButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(fifthButton)
            
        }
        
        //Add the top dismiss button if enabled
        if (promptDismissIconVisibility)
        {
            let dismissButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
            dismissButton.frame = CGRectMake(5, 17, 35, 35)
            dismissButton.addTarget(self, action: "dismissPrompt", forControlEvents: UIControlEvents.TouchUpInside)
            
            swiftPrompt.addSubview(dismissButton)
        }
        
        //Apply animation effect to present this view
        var applicationLoadViewIn = CATransition()
        applicationLoadViewIn.duration = 0.4
        applicationLoadViewIn.type = kCATransitionReveal
        applicationLoadViewIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.layer.addAnimation(applicationLoadViewIn, forKey: kCATransitionReveal)
    }
    
    func panelButtonAction(sender:UIButton?)
    {
        switch (sender!.tag) {
        case 1:
            delegate?.clickedOnTheMainButton?()
        case 2:
            delegate?.clickedOnTheSecondButton?()
        case 3:
            delegate?.clickedOnTheThirdButton?()
        case 4:
            delegate?.clickedOnTheFourthButton?()
        case 5:
            delegate?.clickedOnTheFifthButton?()
        default:
            delegate?.promptWasDismissed?()
        }
    }
    
    // MARK: - Helper Functions
    func snapshot(view: UIView!) -> UIImage!
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, true, 0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        var image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    func dismissPrompt()
    {
        UIView.animateWithDuration(0.6, animations: {
            self.layer.opacity = 0.0
            }, completion: {
                (value: Bool) in
                self.delegate?.promptWasDismissed?()
                self.removeFromSuperview()
        })
    }
    
    // MARK: - API Functions For The Background
    public func setBlurringLevel(level: CGFloat) { blurringLevel = level }
    public func setColorWithTransparency(color: UIColor) { colorWithTransparency = color }
    public func enableBlurringView (enabler : Bool) { enableBlurring = enabler; backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView; }
    public func enableTransparencyWithColorView (enabler : Bool) { enableTransparencyWithColor = enabler; backgroundType = TypeOfBackground.LeveledBlurredWithTransparencyView; }
    public func enableLightEffectView () { backgroundType = TypeOfBackground.LightBlurredEffect }
    public func enableExtraLightEffectView () { backgroundType = TypeOfBackground.ExtraLightBlurredEffect }
    public func enableDarkEffectView () { backgroundType = TypeOfBackground.DarkBlurredEffect }
    
    // MARK: - API Functions For The Prompt
    public func setPromptHeight (height : CGFloat) { promptHeight = height }
    public func setPromptWidth (width : CGFloat) { promptWidth = width }
    public func setPromptHeader (header : String) { promptHeader = header }
    public func setPromptHeaderTxtSize (headerTxtSize : CGFloat) { promptHeaderTxtSize = headerTxtSize }
    public func setPromptContentText (contentTxt : String) { promptContentText = contentTxt }
    public func setPromptContentTxtSize (contentTxtSize : CGFloat) { promptContentTxtSize = contentTxtSize }
    public func setPromptTopBarVisibility (topBarVisibility : Bool) { promptTopBarVisibility = topBarVisibility }
    public func setPromptBottomBarVisibility (bottomBarVisibility : Bool) { promptBottomBarVisibility = bottomBarVisibility }
    public func setPromptTopLineVisibility (topLineVisibility : Bool) { promptTopLineVisibility = topLineVisibility }
    public func setPromptBottomLineVisibility (bottomLineVisibility : Bool) { promptBottomLineVisibility = bottomLineVisibility }
    public func setPromptOutlineVisibility (outlineVisibility: Bool) { promptOutlineVisibility = outlineVisibility }
    public func setPromptBackgroundColor (backgroundColor : UIColor) { promptBackgroundColor = backgroundColor }
    public func setPromptHeaderBarColor (headerBarColor : UIColor) { promptHeaderBarColor = headerBarColor }
    public func setPromptBottomBarColor (bottomBarColor : UIColor) { promptBottomBarColor = bottomBarColor }
    public func setPromptHeaderTxtColor (headerTxtColor  : UIColor) { promptHeaderTxtColor =  headerTxtColor}
    public func setPromptContentTxtColor (contentTxtColor : UIColor) { promptContentTxtColor = contentTxtColor }
    public func setPromptOutlineColor (outlineColor : UIColor) { promptOutlineColor = outlineColor }
    public func setPromptTopLineColor (topLineColor : UIColor) { promptTopLineColor = topLineColor }
    public func setPromptBottomLineColor (bottomLineColor : UIColor) { promptBottomLineColor = bottomLineColor }
    public func enableDoubleButtonsOnPrompt () { enableDoubleButtons = true }
    public func setMainButtonText (buttonTitle : String) { mainButtonText = buttonTitle }
    public func setSecondButtonText (secondButtonTitle : String) { secondButtonText = secondButtonTitle }
    public func setThirdButtonText (thirdButtonTitle : String) { thirdButtonText = thirdButtonTitle }
    public func setFourthButtonText (fourthButtonTitle : String) { fourthButtonText = fourthButtonTitle }
    public func setFifthButtonText (fifthButtonTitle : String) { fifthButtonText = fifthButtonTitle }
    public func setMainButtonColor (colorForButton : UIColor) { mainButtonColor = colorForButton }
    public func setSecondButtonColor (colorForSecondButton : UIColor) { secondButtonColor = colorForSecondButton }
    public func setPromptButtonDividerColor (dividerColor : UIColor) { promptButtonDividerColor = dividerColor }
    public func setPromptButtonDividerVisibility (dividerVisibility : Bool) { promptButtonDividerVisibility = dividerVisibility }
    public func setPromptDismissIconColor (dismissIconColor : UIColor) { promptDismissIconColor = dismissIconColor }
    public func setPromptDismissIconVisibility (dismissIconVisibility : Bool) { promptDismissIconVisibility = dismissIconVisibility }
    func enableGesturesOnPrompt (gestureEnabler : Bool) { enablePromptGestures = gestureEnabler }
    
    // MARK: - Create The Prompt With A UIView Sublass
    class PromptBoxView: UIView
    {
        //Mater Class
        let masterClass : SwiftPromptsView
        
        //Gesture Recognizer Vars
        var lastLocation:CGPoint = CGPointMake(0, 0)
        
        init(master: SwiftPromptsView)
        {
            //Create a link to the parent class to access its vars and init with the prompts size
            masterClass = master
            var promptSize = CGRect(x: 0, y: 0, width: masterClass.promptWidth, height: masterClass.promptHeight)
            super.init(frame: promptSize)
            
            // Initialize Gesture Recognizer
            if (masterClass.enablePromptGestures) {
                var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
                self.gestureRecognizers = [panRecognizer]
            }
        }
        
        required init(coder aDecoder: NSCoder)
        {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func drawRect(rect: CGRect)
        {
            //Call to the SwiftPrompts drawSwiftPrompt func, this handles the drawing of the prompt
            SwiftPrompts.drawSwiftPrompt(frame: self.bounds, backgroundColor: masterClass.promptBackgroundColor, headerBarColor: masterClass.promptHeaderBarColor, bottomBarColor: masterClass.promptBottomBarColor, headerTxtColor: masterClass.promptHeaderTxtColor, contentTxtColor: masterClass.promptContentTxtColor, outlineColor: masterClass.promptOutlineColor, topLineColor: masterClass.promptTopLineColor, bottomLineColor: masterClass.promptBottomLineColor, dismissIconButton: masterClass.promptDismissIconColor, promptText: masterClass.promptContentText, textSize: masterClass.promptContentTxtSize, topBarVisibility: masterClass.promptTopBarVisibility, bottomBarVisibility: masterClass.promptBottomBarVisibility, headerText: masterClass.promptHeader, headerSize: masterClass.promptHeaderTxtSize, topLineVisibility: masterClass.promptTopLineVisibility, bottomLineVisibility: masterClass.promptBottomLineVisibility, outlineVisibility: masterClass.promptOutlineVisibility, dismissIconVisibility: masterClass.promptDismissIconVisibility)
        }
        
        func detectPan(recognizer:UIPanGestureRecognizer)
        {
            if lastLocation==CGPointZero{
                lastLocation = self.center
            }
            var translation  = recognizer.translationInView(self)
            self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
            
            var verticalDistanceFromCenter : CGFloat = fabs(translation.y)
            var horizontalDistanceFromCenter : CGFloat = fabs(translation.x)
            var shouldDismissPrompt : Bool = false
            
            //Dim the prompt accordingly to the specified radius
            if (verticalDistanceFromCenter < 100.0) {
                var radiusAlphaLevel : CGFloat = 1.0 - verticalDistanceFromCenter/100
                self.alpha = radiusAlphaLevel
                //self.superview!.alpha = radiusAlphaLevel
                shouldDismissPrompt = false
            } else {
                self.alpha = 0.0
                //self.superview!.alpha = 0.0
                shouldDismissPrompt = true
            }
            
            //Handle the end of the pan gesture
            if (recognizer.state == UIGestureRecognizerState.Ended)
            {
                if (shouldDismissPrompt == true) {
                    UIView.animateWithDuration(0.6, animations: {
                        self.layer.opacity = 0.0
                        self.masterClass.layer.opacity = 0.0
                        }, completion: {
                            (value: Bool) in
                            self.masterClass.delegate?.promptWasDismissed?()
                            self.removeFromSuperview()
                            self.masterClass.removeFromSuperview()
                    })
                } else
                {
                    UIView.animateWithDuration(0.3, animations: {
                        self.center = self.masterClass.center
                        self.alpha = 1.0
                        //self.superview!.alpha = 1.0
                    })
                }
            }
        }
        
        override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)
        {
            // Remember original location
            lastLocation = self.center
        }
    }
}
