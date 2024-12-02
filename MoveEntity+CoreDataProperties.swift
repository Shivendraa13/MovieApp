//
//  MoveEntity+CoreDataProperties.swift
//  
//
//  Created by Preyash on 27/09/24.
//
//

import Foundation
import CoreData


extension MoveEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MoveEntity> {
        return NSFetchRequest<MoveEntity>(entityName: "MoveEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var poster: String?
    @NSManaged public var title: String?
    @NSManaged public var rating: Double
    @NSManaged public var year: Int64
    @NSManaged public var director: String?

}
