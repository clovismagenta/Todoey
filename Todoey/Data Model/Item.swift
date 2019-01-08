//
//  Item.swift
//  Todoey
//
//  Created by Clovis Magenta da Cunha on 07/01/2019.
//  Copyright © 2019 CMC. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var dataCreated : Date?
    @objc dynamic var hexColor : String = ""
    
    var parentCategory = LinkingObjects(fromType: Category.self, property:"items")
}
