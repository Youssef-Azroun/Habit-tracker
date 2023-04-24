//
//  Activity.swift
//  Habit tracker
//
//  Created by Youssef Azroun on 2023-04-24.
//

import Foundation
import FirebaseFirestoreSwift


struct Activity: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var done: Bool = false
}
