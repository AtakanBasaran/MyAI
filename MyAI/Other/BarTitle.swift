//
//  BarTitle.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI
import FirebaseAuth

struct BarTitle: View {
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var vm: ViewModel
    let action: () -> ()
    
    var body: some View {
        
        HStack {
            
            Button {
                vm.sideMenu = true
                action()
                
                withAnimation(.smooth(duration: 0.5)) {
                    vm.rightMenuAnimate = true
                }
                
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
            }
            .padding(.leading, 20)
            
            
            Spacer()
            
            HStack {
                
                Image(systemName: "bonjour")
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 20))
                    .bold()
                
                Text("MyAI")
                    .font(.title2)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .bold()
            }
    
            
            Spacer()
            
            if vm.viewChatOpen {
                
                Button {
                    vm.deleteConversation()
                    vm.messages = []
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .padding(.trailing, 20)
                

                
            } else {
                
                Menu {
                    
                    VStack {
                        
                        if vm.urlImage != "" {
                            
                            ShareLink(item: URL(string: vm.urlImage)!) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                            }
                        }
                        
                        Button(action: {
                            
                            vm.saveImage(urlString: vm.urlImage)
                            
                        }, label: {
                            
                            Label("Save", systemImage: "square.and.arrow.down")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                        })
                        
                        
                    }
                    
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                .padding(.trailing, 20)
                .opacity(vm.urlImage != "" && !vm.viewChatOpen ? 1 : 0)
                .disabled(vm.urlImage != "" && !vm.viewChatOpen ? false : true)
            }
            
            
            
        }
    }
}

//#Preview {
//    BarTitle()
//}
