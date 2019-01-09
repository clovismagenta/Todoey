//
//  ViewController.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 27/12/2018.
//  Copyright © 2018 CMC. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
//    var itemArray = [ Item ]() // coredate uses it
//    let defaults = UserDefaults()
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    /* COREDATE METHOD - BEGIN
    let actualContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    COREDATA METHOD - END */

    @IBOutlet weak var searchBar: UISearchBar!
    var itemArray : Results<Item>?
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    var catNavBarColor : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // right button "+"
        let buttonAdd = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(addItem))
        let selectColor = UIColor(hexString: selectedCategory!.hexColor)
        
        buttonAdd.tintColor = UIColor(contrastingBlackOrWhiteColorOn: selectColor, isFlat: true)
        navigationItem.rightBarButtonItem = buttonAdd
        
//        if let takeList = defaults.array(forKey: "ToDoList") as? [Item] {
//            itemArray = takeList
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let catHexColor = selectedCategory?.hexColor {
            updateNavColor(hexColor: catHexColor)
            searchBar.barTintColor = UIColor(hexString: catHexColor)
            title = selectedCategory!.name
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavColor(hexColor: catNavBarColor)
    }
    
    //MARK: Tableview datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = super.tableView(tableView, cellForRowAt: indexPath)
        let percentage = CGFloat(indexPath.row) / CGFloat((itemArray?.count)!)
        let selectedItemColor = UIColor(hexString: selectedCategory?.hexColor)
        
        if let cellColor = selectedItemColor?.darken(byPercentage: CGFloat( percentage ) ) {
            itemCell.backgroundColor = cellColor
            itemCell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: cellColor, isFlat: true)
        }
        
        if let actualItem = itemArray?[indexPath.row] {
            itemCell.textLabel?.text = actualItem.title
            
            itemCell.accessoryType = actualItem.done ? .checkmark : .none
        } else {
            itemCell.textLabel?.text = "No Items Added"
        }

        return itemCell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }

    //MARK: Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//
//        actualContext.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
//                    realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                    print("Error on update DONE field: \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        //saveItems()
    }


    //MARK: Add new items
    
    @objc func addItem() {
        
        var globalTextField = UITextField()
//        var format4Date = DateFormatter()
//        var dateFormated = ""
//        let actualDate = Date()
        
        let alertView = UIAlertController(title: "Add a new Todoey", message: "", preferredStyle: .alert)
        let actionAlert = UIAlertAction(title: "Confirm", style: .default) {
            (action) in
  
            /* COREDATA METHOD - BEGIN
            let newItem = Item(context: self.actualContext)
            COREDATA METHOD - END */
            
            if let currentCategory = self.selectedCategory {
                let newItem = Item()
                newItem.title = globalTextField.text!
//                format4Date.dateFormat = "dd.MM.yyyy"
//                dateFormated = format4Date.string(from: actualDate)
                newItem.dataCreated = Date()
                do {
                    try self.realm.write {
                        self.realm.add(newItem)
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving context, \(error)")
                }
                self.tableView.reloadData()
                
                /* COREDATA METHOD - BEGIN
                 newItem.done = false
                 newItem.parentCategory = self.selectedCategory
                 
                 self.itemArray.append(newItem)
                 COREDATA METHOD - END */
                
                    
            }
//                self.defaults.setValue(self.itemArray, forKey: "ToDoList")
        }
        
        alertView.addAction(actionAlert)
        alertView.addTextField { (alertTextField)
            in
            alertTextField.placeholder = "Inform your new Todoey item..."
            globalTextField = alertTextField
        }
        
        present(alertView, animated: true, completion: nil)
    }
    
    
    //MARK: Update UI
    
    func updateUIList() {
        tableView.reloadData()
    }
    
    func saveItems(thisItem : Item) {
        
//        let encoder = PropertyListEncoder()
        
        do {
            try realm.write {
                realm.add(thisItem)
            }
            /* COREDATA METHOD - BEGIN
            try actualContext.save()
            COREDATA METHOD - END */

            //            let data = try encoder.encode(itemArray)
            //            try data.write(to: dataFilePath!)

        } catch {
            print("Error saving context, \(error)")
        }
        updateUIList()
    }
   
    func loadItems() {
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dataCreated", ascending: true)
    }
    
    
    func updateNavColor(hexColor withHexColor: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Bar does not exist!")}
        navBar.barTintColor = UIColor(hexString: withHexColor)
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: navBar.barTintColor, isFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(contrastingBlackOrWhiteColorOn: navBar.barTintColor, isFlat: true)]
        
    }
    
    //MARK: Swipe Class methods
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let posItem = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(posItem)
                }
            } catch {
                print("error during ITEM deletion: \(error)")
            }
        }
        
    }
    
    /* COREDATA METHOD - BEGIN
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ) {

        let standardPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [standardPredicate, additionalPredicate] )
            
        } else {
            
            request.predicate = standardPredicate
        }
        
        do {
            itemArray = try actualContext.fetch(request)
        } catch {
            print("Error during fetch request process: \(error)")
        }
        
////        if let data = try? Data(contentsOf: dataFilePath!) {
////            let decoder = PropertyListDecoder()
//        do {
//
////                itemArray = try decoder.decode([Item].self, from: data)
//        } catch {
//            print("Error on deconding, \(error)")
//        }
    }
    
//    func initialLoad() {
//
//        let newFetch : NSFetchRequest<Item> = Item.fetchRequest()
//        let newPredicate = NSPredicate(format: "parentCategory = %@", (selectedCategory)!)
//
//        newFetch.predicate = newPredicate
//        loadItems(with: newFetch)
//        tableView.reloadData()
//    }
     COREDATA METHOD - END */
    
}

// MARK: Search Bar methods
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.count != 0 {
            if let textTipped = searchBar.text {
                itemArray = itemArray?.filter("title CONTAINS[cd] %@", textTipped).sorted(byKeyPath: "title", ascending: true)
            }
        } else {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
            
        /* COREDATA METHOD - BEGIN
 
        let myRequest : NSFetchRequest<Item> = Item.fetchRequest()
        
        if let textTipped = searchBar.text {
            
            if textTipped == "" {
                
                myRequest.predicate = NSPredicate(format: "title != ''")
                myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                loadItems(with: myRequest)
                tableView.reloadData()

            } else {

                myRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@", textTipped)
                myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
                
                loadItems(with: myRequest)
    
            }
        }
        COREDATA METHOD - END */
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        /* COREDATA METHOD - BEGIN
        let myRequest : NSFetchRequest<Item> = Item.fetchRequest()
        COREDATA METHOD - END */
        
        if searchBar.text?.count != 0 {
            
            if let actualText = searchBar.text {
                itemArray = itemArray?.filter("title CONTAINS[cd] %@", actualText).sorted(byKeyPath: "title", ascending: true)
            }
            
            /* COREDATA METHOD - BEGIN
            let myPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            myRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: myRequest, predicate: myPredicate)
            COREDATA METHOD - END */
            
            
        } else {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            
        }
 
        tableView.reloadData()
    }
}

