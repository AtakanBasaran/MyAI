//
//  MenuView.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI
import FirebaseAuth

enum AppearanceMode: String {
    case dark, light
}

struct MenuView: View {
    
    @EnvironmentObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("apperanceMode") var appearanceMode: AppearanceMode = .light
    
    let action: () -> ()
    let auth = Auth.auth()
    
    var body: some View {
        
        ZStack(alignment: .leading) {
            
            Color(colorScheme == .dark ? .black : .white)
                .frame(width: 300, alignment: .leading)
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                
                VStack(alignment: .leading) {
                    
                    if let email = auth.currentUser?.email {
                        Label(email, systemImage: "person")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding(.leading, 20)
                        
                    }
                    
                    Divider()
                    
                    Button {
                        vm.viewChatOpen = true
                        withAnimation(.smooth(duration: 0.8)){
                            vm.rightMenuAnimate = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
                            vm.sideMenu = false
                            action()
                        }
                        
                    } label: {
                        
                        ZStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 280, height: 35)
                                .foregroundStyle(vm.viewChatOpen ? .gray.opacity(0.7) : .gray.opacity(0.2))
                            
                            Label("ChatAI", systemImage: "message")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .padding(.leading, 20)
                        }
                    }
                    
                    Button {
                        vm.viewChatOpen = false
                        
                        withAnimation(.smooth(duration: 0.8)){
                            vm.rightMenuAnimate = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            vm.sideMenu = false
                            action()
                        }
                    } label: {
                        
                        ZStack(alignment: .leading) {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 280, height: 35)
                                .foregroundStyle(vm.viewChatOpen ? .gray.opacity(0.2) : .gray.opacity(0.7))
                            
                            Label("ImageAI", systemImage: "photo")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .padding(.leading, 20)
                        }
                    }
                    
                    
                }
                .padding(.top, 80)
                
                Divider()
                
                List {
                    ForEach(vm.messagesArray, id: \.self) { conversation in
                        
                        if let firstMessage = conversation.first {
                            Text(firstMessage.content)
                        }
                        
                    }
                }
                .frame(width: 280)
                
                Spacer()
                
                Divider()
                
                Button {
                    appearanceMode = (appearanceMode == .dark) ? .light : .dark
                } label: {
                    
                    ZStack(alignment: .leading) {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 280, height: 35)
                            .foregroundStyle(.gray.opacity(0.2))
                        
                        Label(colorScheme == .dark ? "Dark Mode" : "Light Mode", systemImage: colorScheme == .dark ? "moon.fill" : "sun.min.fill")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding(.leading, 20)
                    }
                }
                
                
                Button(action: {
                    
                    do {
                        try auth.signOut()
                        withAnimation(.easeInOut){
                            vm.navigateChat = false
                        }
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    vm.rightMenuAnimate = false
                    vm.sideMenu = false
                    
                }, label: {
                    
                    ZStack(alignment: .leading) {
                        
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 280, height: 35)
                            .foregroundStyle(.gray.opacity(0.2))
                        
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .padding(.leading, 20)
                    }
                })
                .padding(.bottom, 50)
                
                
            }
            .frame(alignment: .leading)
            .padding(.leading, 10)
            
            
        }
        //        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        //        .ignoresSafeArea()
    }
}


//#Preview {
//    MenuView()
//}
