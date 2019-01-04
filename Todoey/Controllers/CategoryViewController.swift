//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 04/01/2019.
//  Copyright © 2019 CMC. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    let actualContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadCategories()
        tableView.reloadData()
        
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

            let newCategory = Category(context: self.actualContext)
            
            if let newName = globalTextValue.text {
                newCategory.name = newName
                self.commitData()
                self.categoryArray.append(newCategory)
                self.tableView.reloadData()
            }
            
        }
        
        alertScreen.addAction(actionAlert)
        
        present(alertScreen, animated: true)
        
    }
    
    // MARK: Dataview DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let posCell = tableView.dequeueReusableCell(withIdentifier: "catCell", for: indexPath)
        
        posCell.textLabel?.text = categoryArray[indexPath.row].name
        
        return posCell
    }
    
    // MARK: Dataview Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Item clicked: \(categoryArray[indexPath.row].name!)")
        //actualContext.delete(categoryArray[indexPath.row])
        //categoryArray.remove(at: indexPath.row)
        //tableView.reloadData()
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinyStoryBoard = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinyStoryBoard.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
    
    // MARK: Data manipulation Methods
    
    func commitData() {
        
        do {
            try actualContext.save()
        } catch {
            print("error trying to commit: \(error)")
        }
    }
    
    func loadCategories(with: NSFetchRequest<Category> = Category.fetchRequest() ) {
        
        do {
            categoryArray = try actualContext.fetch(with)
        } catch {
            print("error trying to load data: \(error)")
        }
    }
}
