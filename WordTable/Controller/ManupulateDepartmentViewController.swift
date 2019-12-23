//
//  AddDeptViewController.swift
//  WordTable
//
//  Created by Abdinasir Muhumed on 12/7/19.
//  Copyright © 2019 Nasir. All rights reserved.
//

import UIKit
import CoreData

protocol UpdateDeptViewControllerDelegate : class {
    func ManupulateDepartmentViewController(_ controller : ManupulateDepartmentViewController, didFinishAddingDepartment dept : Department, values : [String : String])
}
class ManupulateDepartmentViewController: UIViewController {
    var appdelegate : AppDelegate?
    var department : Department?
    var delegate : UpdateDeptViewControllerDelegate?
    var persistentContainer : NSPersistentContainer!
    private let departmentDescPlaceHolder = "Please delete this text and enter the description of your department"
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    override func viewDidLoad() {
        giveAppropriateTitle()
        if department != nil {
            displayDepartmentInfo()
        }
        super.viewDidLoad()
    }
    @IBAction func cancelButtonClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButtonClicked(_ sender: UIBarButtonItem) {
        if IsvalidValuesEntered() {
            let (name,desc) = getValidValues()
            callAppropriateViewController(name: name, description: desc)
            dismiss(animated: true, completion: nil)
        }else{
            tellUserToEnterValidInfo()
        }
    }
    
    //MARK: - Private functions
    private func IsvalidValuesEntered() -> Bool {
        if nameTextField.text != nil && !nameTextField.text!.isEmpty,
        descriptionTextView.text != nil && descriptionTextView.text != departmentDescPlaceHolder {
            return true
        }
        return false
    }
    
    private func getValidValues() -> (String,String) {
       let name = nameTextField.text ?? "Nothing"
        let desc = descriptionTextView.text ?? "Nothing"
        return (name,desc)
    }
    
    private func tellUserToEnterValidInfo(){
        if descriptionTextView.text == departmentDescPlaceHolder {
            title = "Enter your description"
        } else {
            title = "Enter a name"
        }
    }
    
    private func saveDept(name : String, description : String){
        let dept = Department(context: persistentContainer.viewContext)
        dept.name = name
        dept.deptdescription = description
        appdelegate?.saveContext()
    }
    
    private func updateDept(name : String, description : String) {
        if IsvalidValuesEntered() {
            let disc = ["name" : name, "description" : description]
            delegate?.ManupulateDepartmentViewController(self, didFinishAddingDepartment: department!, values: disc)
        }
    }
    
    private func callAppropriateViewController(name : String, description : String){
        if department != nil {
            updateDept(name: name, description: description)
        }else {
            saveDept(name: name, description: description)
        }
    }
    
    private func giveAppropriateTitle() {
        if department != nil {
            title = "Edit \(department!.name ?? ""))"
        }else {
            title = "Add Department"
        }
    }
    
    private func displayDepartmentInfo(){
        nameTextField.text = department?.name
        descriptionTextView.text = department?.deptdescription
    }
}
