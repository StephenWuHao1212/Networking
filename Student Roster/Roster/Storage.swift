//
//  Storage.swift
//  Roster
//
//  Created by Hao Wu on 10/4/15.
//  Copyright (c) 2015 Hao Wu. All rights reserved.
//

import UIKit

func addStudentToFolder(student:Info){
    var err: NSError?
    let fm = NSFileManager()
    if let suppurl = fm.URLForDirectory(.ApplicationSupportDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false, error: &err){
        let appInfo = suppurl.URLByAppendingPathComponent("AppInfo")
        let studentData = NSKeyedArchiver.archivedDataWithRootObject(student)
        let studentURL = appInfo.URLByAppendingPathComponent(student.name + ".txt")
        studentData.writeToURL(studentURL, atomically: true)
    }
}

func addStudentToGroupAndStudentList(student:Info){
    if groupList[student.groupName] == nil{
        groupList[student.groupName] = [student]
        groupNames.append(student.groupName)
    }
    else{
        groupList[student.groupName]?.append(student)
    }
    studentsList.append(student)
}

func deleteStudentFromFolder(student: Info){
    var err:NSError?
    var paths = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true)[0] as! String
    var appInfoPath = paths.stringByAppendingPathComponent("AppInfo")
    var studentFilePath = appInfoPath.stringByAppendingPathComponent(student.name + ".txt")
    let dm = NSFileManager.defaultManager()
    if (dm.fileExistsAtPath(studentFilePath)) {
        dm.removeItemAtPath(studentFilePath, error: &err)
    }
    
}


func changeStudentInGroupAndStudentList(from: Info, to: Info){
    for var i = 0; i < studentsList.count; i++ {
        if studentsList[i].name == from.name {
            studentsList.removeAtIndex(i)
            break
        }
    }
    for key in groupList.keys {
        if key == from.groupName {
            for var i = 0; i < groupList[key]?.count; i++ {
                if groupList[key]?[i].name == from.name {
                    groupList[key]?.removeAtIndex(i)
                    break
                }
            }
        }
    }
    var newStudent = Info()
    newStudent.name = to.name
    newStudent.countryAndState = to.countryAndState
    newStudent.gender = to.gender
    newStudent.program = to.program
    newStudent.programmingLanguage = to.programmingLanguage
    newStudent.interest = to.interest
    newStudent.groupName = to.groupName
    newStudent.projectName = to.projectName
    newStudent.projectIdea = to.projectIdea
    newStudent.jobExperience = to.jobExperience
    newStudent.completed = to.completed
    newStudent.image = to.image
    newStudent.rating = to.rating
    addStudentToGroupAndStudentList(newStudent)
}

func changeStudentInFolder(from: Info, to: Info){
    deleteStudentFromFolder(from)
    var newStudent = Info()
    newStudent.name = to.name
    newStudent.countryAndState = to.countryAndState
    newStudent.gender = to.gender
    newStudent.program = to.program
    newStudent.programmingLanguage = to.programmingLanguage
    newStudent.interest = to.interest
    newStudent.groupName = to.groupName
    newStudent.projectName = to.projectName
    newStudent.projectIdea = to.projectIdea
    newStudent.jobExperience = to.jobExperience
    newStudent.completed = to.completed
    newStudent.image = to.image
    newStudent.rating = to.rating

    addStudentToFolder(newStudent)
}

var studentsList = [Info]()
var groupList:[String: [Info]] = ["":[]]
var groupNames:[String] = [""]

var filteredInfo = [Info]()
var filteredGroupList:[String:[Info]] = ["":[]]
var filteredGroupNames:[String] = [""]


class Storage: NSObject {
   
}
