//
//  ContentView.swift
//  Habit tracker
//
//  Created by Youssef Azroun on 2023-04-23.
//

import SwiftUI
import Firebase


struct ContentView: View {
    @State var signedIn = false
    var body: some View {
        if !signedIn{
            SignIn(signedIn: $signedIn)
        }else{
            ApplicationStart()
        }
    }
}

struct SignIn: View {
    @Binding var signedIn: Bool
    var auth = Auth.auth()
    
    var body: some View {
        ZStack{
            Color(.gray)
                .ignoresSafeArea()
            VStack{
                Text("Habit Tracker")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Button(action: {
                    auth.signInAnonymously{ Result, error in
                        if let error = error{
                            print("Error signing in \(error)")
                        }else{
                            signedIn = true
                        }
                    }
                },
                       label: {
                    Text("Start")
                        .foregroundColor(.white)
                        .font(.headline)
                        .bold()
                        .padding()
                })
                .background(.black)
                .cornerRadius(15)
                .padding()
            }
        }
    }
}

struct ApplicationStart: View {
    let db = Firestore.firestore()
    @StateObject var activityListVm = ActivitiesList()
    @State var showingAlert = false
    @State var newActivityname = ""
    var body: some View {
        ZStack{
            Color(.gray)
                .ignoresSafeArea()
            VStack{
                List {
                    ForEach(activityListVm.activities) { Activity in
                        RawView(activity: Activity, vm: activityListVm )
                    }
                    .onDelete() { IndexSet in
                        for index in IndexSet {
                            activityListVm.delete(index: index)
                        }
                    }
            }.onAppear{
               // saveToFireStore(activityName: "test")
                activityListVm.listenToFireStore()
                }
                Button(action: {
                    showingAlert = true
                },
                       label: {Text("Add activity")
                        .foregroundColor(.white)
                        .bold()
                        .font(.title)
                        .padding()
                })
                .alert("Add activity", isPresented: $showingAlert) {
                    TextField("Activity name", text: $newActivityname)
                    Button(action: {
                        showingAlert = false
                    }, label: {
                        Text("Cancel")
                    })
                    
                    Button(action: {
                        activityListVm.saveToFireStore(activityName: newActivityname)
                        newActivityname = ""
                    },
                           label: {
                        Text("Add")
                    })
                }
            }
        }
    }
}


struct RawView: View {
    let activity: Activity
    let vm: ActivitiesList
    
    var body: some View {
        HStack{
            Text(activity.name)
            Spacer()
            Button(action: {
                vm.toggel(activity: activity)
            },
                   label: {
                Image(systemName: activity.done ? "checkmark.square" : "square")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
