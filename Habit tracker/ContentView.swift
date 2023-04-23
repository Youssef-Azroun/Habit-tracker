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
    var body: some View {
        Text("Application")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
