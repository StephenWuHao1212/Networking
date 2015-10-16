//
//  Info.swift
//
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//
//  To create information class for one student
//
//
import UIKit

class Info: NSObject, NSCoding {
    var name: String
    var countryAndState: String
    var gender: String
    var program: String
    var programmingLanguage: String
    var interest: String
    var groupName: String
    var projectName: String
    var projectIdea: String
    var jobExperience: String
    var completed: Bool
    var image: UIImage?
    var rating: Int
    override init(){
        name = ""
        countryAndState = ""
        gender = ""
        interest = ""
        program = ""
        programmingLanguage = ""
        groupName = ""
        projectName = ""
        projectIdea = ""
        jobExperience = ""
        image = nil
        completed = false
        rating = -1
    }
    
    init(name:String, interest:String, countryAndState:String, gender:String, program:String, programmingLanguage:String, groupName: String, projectName: String, projectIdea:String, jobExperience: String, image: UIImage!, rating: Int){
        self.name = name
        self.countryAndState = countryAndState
        self.gender = gender
        self.program = program
        self.programmingLanguage = programmingLanguage
        self.interest = interest
        self.groupName = groupName
        self.projectName = projectName
        self.projectIdea = projectIdea
        self.jobExperience = jobExperience
        self.image = image
        self.completed = false
        self.rating = rating
    }

    func encodeWithCoder(coder: NSCoder){
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeObject(self.countryAndState, forKey: "countryAndState")
        coder.encodeObject(self.gender, forKey: "gender")
        coder.encodeObject(self.interest, forKey: "interest")
        coder.encodeObject(self.program, forKey: "program")
        coder.encodeObject(self.programmingLanguage, forKey: "programmingLanguage")
        coder.encodeObject(self.groupName, forKey: "groupName")
        coder.encodeObject(self.projectName, forKey: "projectName")
        coder.encodeObject(self.projectIdea, forKey: "projectIdea")
        coder.encodeObject(self.jobExperience, forKey: "jobExperience")
        coder.encodeObject(self.completed, forKey: "completed")
        if self.image != nil {
            var imageData = UIImageJPEGRepresentation(self.image, 1.0)
            let imageString = imageData.base64EncodedStringWithOptions(.allZeros)
            coder.encodeObject(imageString, forKey: "image")
        }
        else{
            coder.encodeObject("", forKey: "image")
        }
        coder.encodeObject(self.rating, forKey: "rating")
    }
    
    func equalTo(student: Info)->Bool {
        if((self.name != student.name) || (self.gender != student.gender) || (self.countryAndState != student.countryAndState) || (self.program != student.program) || (self.programmingLanguage != student.programmingLanguage) || (self.interest != student.interest) || (self.groupName != student.groupName) || (self.projectName != student.projectName) || (self.projectIdea != student.projectIdea) || (self.jobExperience != student.jobExperience) || (self.image != student.image) || (self.rating != student.rating)) {
                return false
        }
        return true
    }
    
    required init(coder: NSCoder){
        if coder.decodeObjectForKey("name") != nil{
            self.name = coder.decodeObjectForKey("name")! as! String
        }
        else{
            self.name = ""
        }
        
        if coder.decodeObjectForKey("countryAndState") != nil{
            self.countryAndState = coder.decodeObjectForKey("countryAndState")! as! String
        }
        else{
            self.countryAndState = ""
        }
        
        if coder.decodeObjectForKey("gender") != nil{
            self.gender = coder.decodeObjectForKey("gender")! as! String
        }
        else{
            self.gender = ""
        }
        
        if coder.decodeObjectForKey("program") != nil{
            self.program = coder.decodeObjectForKey("program")! as! String
        }
        else{
            self.program = ""
        }
        
        if coder.decodeObjectForKey("programmingLanguage") != nil{
            self.programmingLanguage = coder.decodeObjectForKey("programmingLanguage")! as! String
        }
        else{
            self.programmingLanguage = ""
        }
        
        if coder.decodeObjectForKey("interest") != nil{
            self.interest = coder.decodeObjectForKey("interest")! as! String
        }
        else{
            self.interest = ""
        }
        
        if coder.decodeObjectForKey("groupName") != nil {
            self.groupName = coder.decodeObjectForKey("groupName")! as! String
        }
        else{
            self.groupName = ""
        }
        
        if coder.decodeObjectForKey("projectName") != nil{
            self.projectName = coder.decodeObjectForKey("projectName")! as! String
        }
        else{
            self.projectName = ""
        }
        
        if coder.decodeObjectForKey("projectIdea") != nil{
            self.projectIdea = coder.decodeObjectForKey("projectIdea")! as! String
        }
        else{
            self.projectIdea = ""
        }
        
        if coder.decodeObjectForKey("jobExperience") != nil{
            self.jobExperience = coder.decodeObjectForKey("jobExperience")! as! String
        }
        else{
            self.jobExperience = ""
        }
        
        if coder.decodeObjectForKey("completed") != nil{
            self.completed = coder.decodeObjectForKey("completed")! as! Bool
        }
        else{
            self.completed = false
        }
        
        if coder.decodeObjectForKey("image") != nil && coder.decodeObjectForKey("image")! as! String != "" {
                let imageString = coder.decodeObjectForKey("image")! as! String
                let imageData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions(rawValue: 0))
                var decodedImage = UIImage(data: imageData!)
                self.image = decodedImage
        }
        else{
            self.image = nil
        }
        
        if coder.decodeObjectForKey("rating") != nil {
            self.rating = coder.decodeObjectForKey("rating")! as! Int
        }
        else{
            self.rating = -1
        }
        
        super.init()
    }
    
    
}
