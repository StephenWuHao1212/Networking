//
//  Students.swift
//  Roster
//
//  Created by Hao Wu on 9/21/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit

class Students {
    var studentNames = [
        "TC Dong",
        "Weidong Duan",
        "Shuai Fu",
        "Shaoyi Han",
        "Rahul Harikrishnan",
        "Wenting Hu",
        "Jingxiong Huang",
        "Zhuo Jia",
        "Deyu Jiao",
        "Allan Kiplagat",
        "Ashwin Kommajesula",
        "Austin Kyker",
        "Hao Li",
        "Jiancheng Li",
        "Guoshan Liu",
        "Mingming Lu",
        "Xin Lu",
        "Chase Malik",
        "Julien Mansier",
        "Greg McKeon",
        "Weichen Ning",
        "Zachary Podbela",
        "Scotty Shaw",
        "Emmanuel Shiferaw",
        "Weiqi Wei",
        "Hao Wu",
        "Boyang Xu",
        "Shuai Yuan",
        "Ran Zhou",
        "Hong Jin"]
    
    var students = [Info]()
    
    func appendInfo(name:String, interest:String, countryAndState:String, gender:String, program: String, programmingLanguage:String, groupName: String, projectName: String, projectIdea: String, jobExperience: String, image: UIImage?, rating: Int){
        let student = Info(name:name, interest:interest, countryAndState:countryAndState, gender:gender, program: program, programmingLanguage:programmingLanguage, groupName: groupName, projectName: projectName, projectIdea: projectIdea, jobExperience: jobExperience, image:image!, rating: rating)
        students.append(student)
    }
    
    func getInfoFor(studentName:String) -> Info{
        for student in students{
            if student.name ==  studentName{
                return student
            }
        }
        return Info()
    }
    
    
    init(){
        appendInfo("TC Dong", interest: "violin", countryAndState: "South Africa", gender: "Female", program: "Master in ECE", programmingLanguage: "Java and C", groupName: "Bug Free", projectName: "Remote Classroom",projectIdea: "online education app", jobExperience: "summer intern in IBM", image: UIImage(named: "TC Dong.jpg"), rating: -1)
        appendInfo("Weidong Duan", interest: "swimming and movies", countryAndState: "China", gender: "Male", program: "Bachelor in ECE", programmingLanguage: "C++ and Java", groupName: "Hello World", projectName: "Knected",projectIdea: "app that helps people make friends and share interests", jobExperience: "never worked before", image: UIImage(named: "Weidong Duan.jpg"), rating: -1)
        appendInfo("Shuai Fu", interest: "piano and table tennis", countryAndState: "China", gender: "Male", program: "Bachelor in ECE", programmingLanguage: "Java and C", groupName: "Apple Pie", projectName: "Cleft Community",projectIdea: "maybe a game", jobExperience: "never worked before", image: UIImage(named: "Shuai Fu.jpg"), rating: -1)
        appendInfo("Shaoyi Han", interest: "piano and dancing", countryAndState: "China", gender: "Female", program: "Bachelor in EE and master in ECE", programmingLanguage: "C++ and C", groupName: "HelloSiri", projectName: "Peer Evaluation",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Shaoyi Han.jpg"), rating: -1)
        appendInfo("Rahul Harikrishnan", interest: "cricket and hiking", countryAndState: "Washington, USA", gender: "Male",program: "Bachelor in CE and EE double major", programmingLanguage: "Java and Python", groupName: "Si! Mas!", projectName: "CIEMAS Map",projectIdea: "hasn't thought about it", jobExperience: "Apptio Internship", image: UIImage(named: "Rahul Harikrishnan.jpg"), rating: -1)
        appendInfo("Wenting Hu", interest: "piano and computer games", countryAndState: "China", gender: "Female", program: "Master in ECE", programmingLanguage: "C and C++", groupName: "10", projectName: "TBD",projectIdea: "develop intelligent watt hour meters, scheduling app using gamification to solve procrastination", jobExperience: "never worked before", image: UIImage(named: "Wenting Hu.jpg"), rating: -1)
        appendInfo("Jingxiong Huang", interest: "swimming and mobile phone gamges", countryAndState: "China", gender: "Male", program: " Master in ECE",programmingLanguage: "C++ and Python", groupName: "Apple Farm", projectName: "Farm Shots",projectIdea: "maybe a game", jobExperience: "never worked before", image: UIImage(named: "Jingxiong Huang.jpg"), rating: -1)
        appendInfo("Zhuo Jia", interest: "cooking and photoshooting", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C++ and Java", groupName: "Hello World", projectName: "Knected",projectIdea: "summer intern in a start-up company in China", jobExperience: "hasn't thought about it", image: UIImage(named: "Zhuo Jia.jpg"), rating: -1)
        appendInfo("Deyu Jiao", interest: "choir and piano", countryAndState: "China", gender: "Male", program:  "Bachelor in Information Engineering", programmingLanguage: "C++ and Java", groupName: "WJL", projectName: "Careen Fair",projectIdea: "summer intern in China, cloud address book", jobExperience: "hasn't thought about it", image: UIImage(named: "Deyu Jiao.jpg"), rating: -1)
        appendInfo("Allan Kiplagat", interest: "guitar and jogging", countryAndState: "Kenya", gender: "Male", program: "Bachelor in ECE and CS", programmingLanguage: "Java and Ruby", groupName: "Si! Mas!", projectName: "CIEMAS Map",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Allan Kiplagat.jpg"), rating: -1)
        appendInfo("Ashwin Kommajesula", interest: "cooking and violin", countryAndState: "New Jersey, USA, but born in India", gender: "Male", program: "Bachelor in ECE", programmingLanguage: "Java and C", groupName: "10", projectName: "TBD",projectIdea: "hasn't thought about it", jobExperience: "Quicken Loans", image: UIImage(named: "Ashwin Kommajesula.jpg"), rating: -1)
        appendInfo("Austin Kyker", interest: "basketball and golf", countryAndState: "Indiana, USA", gender: "Male", program: "Bachelor in CS", programmingLanguage: "Java and C", groupName: "Shooting Guards", projectName: "TBD",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Austin Kyker.jpg"), rating: -1)
        appendInfo("Hao Li", interest: "basketball and movies", countryAndState: "China", gender: "Male", program:  "Master in ECE and Bachelor in EE", programmingLanguage: "C++ and Java", groupName: "Physaologists", projectName: "Physao",projectIdea: "maybe a game", jobExperience: "never worked before", image: UIImage(named: "Hao Li.jpg"), rating: -1)
        appendInfo("Jiancheng Li", interest: "swimming and computer games", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C and Java", groupName: "Hello World", projectName: "Knected",projectIdea: "online system to share fantastic foods you had", jobExperience: "never worked before", image: UIImage(named: "Jiancheng Li.jpg"), rating: -1)
        appendInfo("Guoshan Liu", interest: "piano and music", countryAndState: "China", gender: "Female", program: "Master in ECE", programmingLanguage: "Java and C++",groupName: "WJL", projectName: "Careen Fair",projectIdea: "maybe a game", jobExperience: "never worked before", image: UIImage(named: "Guoshan Liu.jpg"), rating: -1)
        appendInfo("Mingming Lu", interest: "basketball and workout", countryAndState: "China", gender: "Male", program: "Master in ECE and Bachelor in Electrical and Information Engineering", programmingLanguage: "C++ and Java", groupName: "Apple Pie", projectName: "Cleft Community",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Mingming Lu.jpg"), rating: -1)
        appendInfo("Xin Lu", interest: "running and table tennis", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C++ and Go", groupName: "Apple Farm", projectName: "Farm Shots",projectIdea: "expense tracking app", jobExperience: "summer intern in a start-up, cloud computing company in China", image: UIImage(named: "Xin Lu.jpg"), rating: -1)
        appendInfo("Chase Malik", interest: "video games and watching sports", countryAndState: "Missouri, USA", gender: "Male", program: "Bachlor in EE, CS, Math triple major", programmingLanguage: "Java and C", groupName: "Shooting Guards", projectName: "TBD",projectIdea: "hasn't thought about it", jobExperience: "sporting innovation", image: UIImage(named: "Chase Malik.jpg"), rating: -1)
        appendInfo("Julien Mansier", interest: "football and beer brewing", countryAndState: "Florida, USA", gender: "Male", program: "Master in EE", programmingLanguage: "Java and C", groupName: "Si! Mas!", projectName: "CIEMAS Map",projectIdea: "BI Tool", jobExperience: "Auto industry", image: UIImage(named: "Julien Mansier.jpg"), rating: -1)
        appendInfo("Greg McKeon", interest: "Netflix and baseball", countryAndState: "New York, USA", gender: "Male", program: "Bachelor in ECE and CS", programmingLanguage: "Java and Javascript", groupName: "Apple Farm", projectName: "Farm Shots",projectIdea: "hasn't thought about it", jobExperience: "American Express", image: UIImage(named: "Greg McKeon.jpg"), rating: -1)
        appendInfo("Weichen Ning", interest: "badminton and movie", countryAndState: "China", gender: "Male", program: "Master in ECE and Bachelor in EE", programmingLanguage: "C and C++", groupName: "Apple Pie", projectName: "Cleft Community",projectIdea: "hasn't thought about it", jobExperience: "summer intern in Cisco", image: UIImage(named: "Weichen Ning.jpg"), rating: -1)
        appendInfo("Zachary Podbela", interest: "music and flying", countryAndState: "New York, USA", gender: "Male", program: "Master in ECE", programmingLanguage: "Java and Python", groupName: "10", projectName: "TBD",projectIdea: "hasn't thought about it", jobExperience: "capital one labs", image: UIImage(named: "Zachary Podbela.jpg"), rating: -1)
        appendInfo("Scotty Shaw", interest: "Baketball and traveling", countryAndState: "Texas, USA", gender: "Male", program: "Bachelor in CS", programmingLanguage: "Java and Python", groupName: "Shooting Guards", projectName: "TBD",projectIdea: "Google map with weather display or Dos Equis Alram Clock", jobExperience: "HackWare, LLC", image: UIImage(named: "Scotty Shaw.jpg"), rating: -1)
        appendInfo("Emmanuel Shiferaw", interest: "reading and football", countryAndState: "North Carolina, USA", gender: "Male", program: "Bachelor in ECE", programmingLanguage: "Java and C#", groupName: "Physaologists", projectName: "Physao",projectIdea: "ipad app that connects with virtual reality experience", jobExperience: "DiVE", image: UIImage(named: "Emmanuel Shiferaw.jpg"), rating: -1)
        appendInfo("Weiqi Wei", interest: "soccer and table tennis", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C++ and Java", groupName: "Physaologists", projectName: "Physao",projectIdea: "maybe Apple Watch app", jobExperience: "never worked before", image: UIImage(named: "Weiqi Wei.jpg"), rating: -1)
        appendInfo("Hao Wu", interest: "tennis and movie", countryAndState: "China", gender: "Male", program: "Master in ECE and Bachelor in EE", programmingLanguage: "Java and C", groupName: "WJL", projectName: "Careen Fair",projectIdea: "hasn't thought about it", jobExperience: "Witricity Corporation", image: UIImage(named: "Hao Wu.jpg"), rating: -1)
        appendInfo("Boyang Xu", interest: "basketball and soccer", countryAndState: "China", gender: "Male", program: "Master in CS", programmingLanguage: "C and Java", groupName: "HelloSiri", projectName: "Peer Evaluation",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Boyang Xu.jpg"), rating: -1)
        appendInfo("Shuai Yuan", interest: "basketball and computer games", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C and Java", groupName: "Bug Free", projectName: "Remote Classroom",projectIdea: "not a game", jobExperience: "never worked before", image: UIImage(named: "Shuai Yuan.jpg"), rating: -1)
        appendInfo("Ran Zhou", interest: "violin and swimming", countryAndState: "China", gender: "Female", program: "Master in MEng ECE", programmingLanguage: "C++ and C", groupName: "Bug Free", projectName: "Remote Classroom",projectIdea: "summer intern in Schneider Electric, China", jobExperience: "fitnexx app", image: UIImage(named: "Ran Zhou.jpe"), rating: -1)
        appendInfo("Hong Jin", interest: "basketball and computer games", countryAndState: "China", gender: "Male", program: "Master in ECE", programmingLanguage: "C and C++", groupName: "HelloSiri", projectName: "Peer Evaluation",projectIdea: "hasn't thought about it", jobExperience: "never worked before", image: UIImage(named: "Hong Jin.jpg"), rating: -1)
    }
}
