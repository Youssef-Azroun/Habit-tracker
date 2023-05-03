//
//  ActivitiesList.swift
//  Habit tracker
//
//  Created by Youssef Azroun on 2023-04-24.
//

import Foundation
import Firebase
import SwiftUI
import FirebaseFirestoreSwift

class ActivitiesList : ObservableObject {
    @Published var activities = [Activity]()
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    
    func delete(index: Int) {
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        
        let activity = activities[index]
        if let id = activity.id{
            activityRef.document(id).delete()
        }
    }
    
    func toggel (activity: Activity) {
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if let id = activity.id{
            activityRef.document(id).updateData(["done" : !activity.done])
            if !activity.done && activity.latestDate == today{
                activityRef.document(id).updateData(["streak": FieldValue.increment(Int64(1))])
            }else if activity.done && activity.latestDate == today {
                activityRef.document(id).updateData(["streak": FieldValue.increment(Int64(-1))])
            } else if (!activity.done && activity.latestDate < yesterday){
                activityRef.document(id).updateData(["streak": 1])
                activityRef.document(id).updateData(["latestDate": today])
            }else if (!activity.done && activity.latestDate >= yesterday) {
                activityRef.document(id).updateData(["streak": FieldValue.increment(Int64(1))])
                activityRef.document(id).updateData(["latestDate": today])
            }
        }
    }
    
    func saveToFireStore(activityName: String) {
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        let latestDate = Calendar.current.startOfDay(for: Date())
        let activity = Activity(name: activityName, latestDate: latestDate)
        
        do{
          try activityRef.addDocument(from: activity)
        }catch{
            print("Error saving to fireStore")
        }
    }
    
    func listenToFireStore() {
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        
        activityRef.addSnapshotListener() {
            snapshot, error in
            guard let snapshot = snapshot else{return}
            if let error = error{
                print("Error listning to firestore\(error)")
            }else{
                self.activities.removeAll()
                for document in snapshot.documents{
                    do{
                    let activity = try document.data(as: Activity.self)
                        self.restartDone(activity: activity)
                        self.activities.append(activity)
                    }catch{
                        print("Error reading from fireStore")
                    }
                }
            }
        }
    }
    
    func restartDone(activity: Activity){
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if let id = activity.id {
            if activity.latestDate < today && activity.latestDate > yesterday{
                activityRef.document(id).updateData(["done" : false])
                activityRef.document(id).updateData(["latestDate" : today])
            }else if activity.latestDate < yesterday {
                activityRef.document(id).updateData(["streak" : 0])
                activityRef.document(id).updateData(["done" : false])
                activityRef.document(id).updateData(["latestDate" : today])
            }
        }
    }
}
