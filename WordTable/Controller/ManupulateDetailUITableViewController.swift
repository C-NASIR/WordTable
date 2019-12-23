//
//  AddDetailViewController.swift
//  WordTable
//
//  Created by Abdinasir Muhumed on 12/7/19.
//  Copyright © 2019 Nasir. All rights reserved.
//

import UIKit
import CoreData
protocol UpdateDetailViewControllerDelegate{
    func ManupulateDetailUITableViewController(_ controller : ManupulateDetailUITableViewController, didFinishAddingTerm term : Term, department dept : Department, values : [String : String])
}
class ManupulateDetailUITableViewController: UITableViewController {
    var appDelegate : AppDelegate?
    var persistentContainer : NSPersistentContainer?
    var term : Term?
    var department : Department!
    var delegate : UpdateDetailViewControllerDelegate?
    //Text Fields
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var spanishTextField: UITextField!
    @IBOutlet weak var somaliTextField: UITextField!
    @IBOutlet weak var hmongTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        giveAppropriateTitle()
        if term != nil {
            displayDetailInfo()
        }
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        if isAloneDepartmentOrTermDepartmentAvailable() {
            callAppropriateSaveTerms()
            dismiss(animated: true, completion: nil)
        } else {
            print("There is a bug: There is no term's department or variable department in Manu ManupulateDetailUITableViewController")
        }
    }

    private func isAloneDepartmentOrTermDepartmentAvailable() -> Bool {
        if department != nil || term?.department != nil {
            return true
        }else {
            return false
        }
    }
    
    private func callAppropriateSaveTerms(){
        if IsvalidValuesEntered() {
            let dic = getValidValues()
            let dept = getDepartment()
            callAppropriateViewController(name: dic["name"]!, description: dic["description"]!, spanish: dic["spanish"]!, somali: dic["somali"]!, hmong: dic["hmong"]!, department: dept)
        } else {
            tellUserToEnterValidInfo()
        }
    }
    
    private func getDepartment() -> Department {
        if department != nil {
            return department
        }else {
            return term!.department!
        }
    }
    
    private func callAppropriateViewController(name : String, description desc : String,spanish : String, somali: String, hmong : String, department dept : Department){
           if term == nil {
                saveTerm(name : name, description : desc, spanish : spanish, somali : somali, hmong : hmong ,department : dept)
           } else {
              updateTerm(name: name, description: desc, spanish: spanish, somali: somali, hmong: hmong, department: dept)
           }
    }
    
    private func saveTerm(name : String, description desc : String,spanish : String, somali: String, hmong : String, department dept : Department){
        let term = Term(context: persistentContainer!.viewContext)
        term.english = name
        term.termdescription = desc
        term.spanish = spanish
        term.somali = somali
        term.hmong = hmong
        term.department = dept
        appDelegate!.saveContext()
    }
    
    private func updateTerm(name : String, description desc : String,spanish : String, somali: String, hmong : String, department dept : Department) {
        let dic = ["name" : name,"spanish" : spanish, "somali" : somali, "description" : desc, "hmong" : hmong]
        delegate?.ManupulateDetailUITableViewController(self, didFinishAddingTerm: term!, department: dept, values: dic)
    }
    
    //MARK: - Private Methods
    private func IsvalidValuesEntered() -> Bool {
        guard nameTextField.text != nil && !nameTextField.text!.isEmpty else { return false }
        return true
    }
       
    private func getValidValues() -> [String:String] {
        var result = ["":""]
        guard let name = nameTextField.text else { return result}
        guard let spanish = spanishTextField.text else { return  result}
        guard let somali = somaliTextField.text else { return result}
        guard let desc = descriptionTextField.text else { return result}
        guard let hmong = hmongTextField.text else { return result}
        result = ["name" : name,"spanish" : spanish, "somali" : somali, "description" : desc, "hmong" : hmong]
        return result
    }
       
    private func tellUserToEnterValidInfo(){
        title = "Please Enter Name"
    }
    
    private func giveAppropriateTitle() {
        if let name = term?.english {
            title = "Edit \(name)"
        } else {
            title = "Add Term"
        }
    }
    private func displayDetailInfo(){
        nameTextField.text = term?.english
        descriptionTextField.text = term?.termdescription
        spanishTextField.text = term?.spanish
        somaliTextField.text = term?.somali
        hmongTextField.text = term?.hmong
    }
}
