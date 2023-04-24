//
//  ActivitiesList.swift
//  Habit tracker
//
//  Created by Youssef Azroun on 2023-04-24.
//

import Foundation
import Firebase

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
        
        if let id = activity.id{
            activityRef.document(id).updateData(["done" : !activity.done])
        }
    }
    
    func saveToFireStore(activityName: String) {
        guard let user = auth.currentUser else{return}
        let activityRef = db.collection("Users").document(user.uid).collection("Activities")
        let activity = Activity(name: activityName)
        
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
                        self.activities.append(activity)
                    }catch{
                        print("Error reading from fireBase")
                    }
                }
            }
        }
    }
}
