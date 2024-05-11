//
//  ChatBotView.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI

struct ChatBotView: View {
    
    @EnvironmentObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var message: String = ""
    @FocusState private var dismissKeyboard: Bool
    @State private var messageEmpty = false
    @State private var scrollDown = false
    
    
    var body: some View {
        
        NavigationStack {
            
            ZStack(alignment: .leading) {
                
                ZStack {
                    
                    GeometryReader { geo in
                        VStack {
                            
                            BarTitle(action: {
                                dismissKeyboard = false
                                scrollDown.toggle()
                            })
                            .padding(.top, 5)

                            
                            if vm.viewChatOpen {
                                
                                VStack {
                                    
                                    ScrollViewReader { scroll in
                                        
                                        ZStack {
                                            
                                            ScrollView {
                                                
                                                VStack {
                                                    
                                                    ForEach(vm.messages) { message in
                                                        
                                                        Messages(message: message)
                                                    }
                                                }
                                                .id("messages")
                                                .onChange(of: vm.messages.count) { _ in
                                                    
                                                    withAnimation(.smooth) {
                                                        scroll.scrollTo("messages", anchor: .bottom)
                                                    }
                                                }
                                                
                                                .onChange(of: dismissKeyboard) { value in
                                                    print("keyboard: \(value)")
                                                    if dismissKeyboard {
                                                        withAnimation(.smooth) {
                                                            scroll.scrollTo("messages", anchor: .bottom)
                                                        }
                                                    }
                                                }
                                                
                                                .onChange(of: scrollDown) { _ in
                                                    withAnimation(.smooth) {
                                                        scroll.scrollTo("messages", anchor: .bottom)
                                                    }
                                                }
                                                
                                                
                                            }
                                            
                                            if vm.messages.isEmpty {
                                                Image(systemName: "bonjour")
                                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                                    .font(.system(size: 50))
                                            }
                                        }
                                        
                                    }
                                }
                                .onTapGesture(perform: {
                                    dismissKeyboard = false
                                })
                                
                                
                            } else {
                                
                                ScrollView {
                                    
                                    ZStack {
                                        
                                        AsyncImage(url: URL(string: vm.urlImage)) { image in
                                            
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(.rect(cornerRadius: 15))
                                                .padding()
                                            
                                        } placeholder: {
                                            Image("grayImage")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .clipShape(.rect(cornerRadius: 15))
                                                .padding()
                                            
                                        }
                                        
                                        if vm.loadingImage {
                                            ProgressView()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .frame(width: 40, height: 40)
                                                        .foregroundStyle(.gray)
                                                )
                                        }
                                    }
                                    .onTapGesture {
                                        dismissKeyboard = false
                                    }
                                }
                                
                            }
                            
                            Spacer()
                            

                            HStack {
                                
                                TextField("What's in your mind?", text: $message, axis: .vertical)
                                    .focused($dismissKeyboard)
                                    .submitLabel(.send)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 15))
      
                                
                                    .onChange(of: message) { _ in
                                        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
                                        messageEmpty = trimmedMessage.isEmpty
                                    }
                                
                                
                                Button {
                                    let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    if !trimmedMessage.isEmpty {
                                        
                                        if vm.viewChatOpen {
                                            vm.sendMessage(message: message)
                                        } else {
                                            vm.sendImageMessage(prompt: message)
                                            dismissKeyboard = false
                                        }
                                        
                                        message = ""
                                    }
                                    
                                } label: {
                                    Image(systemName: "paperplane")
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                                .disabled(messageEmpty)
                                .opacity(messageEmpty ? 0.3 : 1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                        }
                        .offset(x: vm.rightMenuAnimate ? 300 : 0)
                        
                    }
                    
                    
                    if vm.rightMenuAnimate {
                        Color.gray.opacity(0.3)
                            .ignoresSafeArea()
                    } else {
                        Color.clear
                            .ignoresSafeArea()
                    }
                }
                
                
                if vm.sideMenu {
                    
                    ZStack {
                        
                        HStack(spacing: 0) {
                            
                            MenuView(action: {
                                dismissKeyboard = true
                            })
                            .offset(x: vm.rightMenuAnimate ? 0 : -300)
                            
                            
                            Color.gray.opacity(0.0000001)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    
                                    withAnimation(.smooth(duration: 0.8)){
                                        vm.rightMenuAnimate = false
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8){
                                        vm.sideMenu = false
                                        dismissKeyboard = true
                                    }
                                    
                                }
                            
                        }
                        .ignoresSafeArea()
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .ignoresSafeArea()
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    
                    if value.translation.width > 50 {
                        
                        dismissKeyboard = false
                        vm.sideMenu = true
                        
                        withAnimation(.smooth(duration: 0.5)) {
                            vm.rightMenuAnimate = true
                        }
                    }
                    
                    if value.translation.width < -50 {
                        
                        withAnimation(.smooth(duration: 0.5)){
                            vm.rightMenuAnimate = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            vm.sideMenu = false
                            dismissKeyboard = true
                        }
                        
                    }
                })
        )
        
        
        
        .onAppear(perform: {
            dismissKeyboard = true
        })
        .task {
            vm.getConversations()
            
        }
        
        .alert("Success!", isPresented: $vm.alertSuccessUp) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Your Account Created Successfully")
        }
        
        .alert("Error!", isPresented: $vm.errorDownloadImg) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Error downloading image, please try again.")
        }
        
        .alert("Success!", isPresented: $vm.successDownloadImg) {
//            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Image is saved to library.")
        }
        
    }

}

#Preview {
    ChatBotView()
}
