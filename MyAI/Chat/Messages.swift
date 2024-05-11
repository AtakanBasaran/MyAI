//
//  Messages.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI

struct Messages: View {
    
    let message: Message
    
    var body: some View {
        
        Group {
            
            if message.isUser {
                
                HStack {
                    
                    Spacer()
                    
                    Text(message.content)
                        .padding(10)
                        .background(Color.green)
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                }
                .padding(.vertical, 10)
                .padding(.trailing, 15)
                .padding(.leading, 30)
                
            } else {
                
                HStack {
                    
                    Text(message.content)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(.rect(cornerRadius: 20))
                        .foregroundStyle(.white)
                        .textSelection(.enabled)
                    
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.leading, 15)
                .padding(.trailing, 30)
            }
            
            
        }
    }
}

//#Preview {
//    Messages()
//}
