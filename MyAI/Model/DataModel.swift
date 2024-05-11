//
//  DataModel.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import Foundation

struct Message: Identifiable, Hashable {
    
    var id = UUID()
    var content: String
    var isUser: Bool
    
    var dictionary: [String:Any] {
        
        return [
            "id": id.uuidString,
            "content": content,
            "isUser": isUser
        ]
    }
}
