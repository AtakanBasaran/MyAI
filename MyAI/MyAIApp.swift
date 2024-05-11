//
//  MyAIApp.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
    
    @EnvironmentObject var vm: ViewModel
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
}


@main
struct MyAIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var vm = ViewModel()
    @State private var signedIn = false
    @Environment(\.scenePhase) var scenePhase
    @AppStorage("apperanceMode") var appearanceMode: AppearanceMode = .light
    
    var body: some Scene {
        
        WindowGroup {
            
            if Auth.auth().currentUser == nil || signedIn {
                
                SignView()
                    .environmentObject(vm)
                    .preferredColorScheme(appearanceMode == .dark ? .dark : .light)

            } else {
                ChatBotView()
                    .environmentObject(vm)
                    .preferredColorScheme(appearanceMode == .dark ? .dark : .light)
                    .onChange(of: scenePhase) { value in
                        if value == .background || value == .inactive {
                            vm.deleteConversation()
                            vm.uploadConversations()
                        }
                    }
            }
            
        }
        
    }
}
