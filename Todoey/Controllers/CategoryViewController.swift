//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 04/01/2019.
//  Copyright © 2019 CMC. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var hexValueBackColor : String = ""
    var categoryArray : Results<Category>? // Optional variable
    var catColor : UIColor?
    /* COREDATA METHOD - BEGIN
    var categoryArray = [Category]()

     let actualContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     COREDATA METHOD - END */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadCategories()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if hexValueBackColor == "" {
            guard let catNavColor = navigationController?.navigationBar.barTintColor else { fatalError() }
            
            hexValueBackColor = catNavColor.hexString
        }
        
        
    }

    // MARK: Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var globalTextValue = UITextField()
        let alertScreen = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)

        alertScreen.addTextField { (textAlert) in
            textAlert.placeholder = "Type category name here"
            globalTextValue = textAlert
            
        }
        
        let actionAlert = UIAlertAction(title: "Confirm", style: .default) { (action) in

            /* COREDATA METHOD - BEGIN
            let newCategory = Category(context: self.actualContext)
            COREDATA METHOD - END */
            let newCategory = Category()
            let color = UIColor.randomFlat()?.hexString
            
            if let newName = globalTextValue.text {
                newCategory.name = newName
                newCategory.hexColor = color!
                self.commitData(thisCategory: newCategory)
//                self.categoryArray.append(newCategory)
                self.tableView.reloadData()
            }
 
        }
        
        alertScreen.addAction(actionAlert)
        
        present(alertScreen, animated: true)
        
    }
    
    // MARK: Dataview DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1 // If it is null, then use value 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let posCell = super.tableView(tableView, cellForRowAt: indexPath)
        
        posCell.textLabel?.text = categoryArray?[indexPath.row].name ?? "Category not added yet"
        posCell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: posCell.backgroundColor, isFlat: true)
        
        posCell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].hexColor)
       
        return posCell
    }
    
    // MARK: Dataview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //actualContext.delete(categoryArray[indexPath.row])
        //categoryArray.remove(at: indexPath.row)
        //tableView.reloadData()
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinyStoryBoard = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinyStoryBoard.selectedCategory = categoryArray?[indexPath.row]
            destinyStoryBoard.catNavBarColor = hexValueBackColor
        }
        
    }
    
    // MARK: Data manipulation Methods
    
    func commitData(thisCategory:Category) {
        
        do {
            try realm.write {
                realm.add(thisCategory)
            }
        } catch {
            
        }
        
        /* COREDATA METHOD - BEGIN
        do {
            try actualContext.save()
        } catch {
            print("error trying to commit: \(error)")
        }
    COREDATA METHOD - END */
    }
    
    /* COREDATA METHOD - BEGIN
    func loadCategories(with: NSFetchRequest<Category> = Category.fetchRequest() ) {
        
        do {
            categoryArray = try actualContext.fetch(with)
        } catch {
            print("error trying to load data: \(error)")
        }
 
    }

     COREDATA METHOD - END */
    
    func loadCategories() {
        
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let category = categoryArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Problems to delete Category: \(error)")
            }
            
        }
        
        
    }
}
