//
//  ViewModel.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI
import OpenAI
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore


enum signUp {
    case success, error
}

enum signIn {
    case success, error
}

final class ViewModel: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var messagesArray: [[Message]] = [[]]
    @Published var urlImage = ""
    
    @Published var signUp: signUp? = nil
    @Published var signIn: signIn? = nil
    @Published var error: String = ""
    @Published var errorDownloadImg = false
    @Published var successDownloadImg = false
    
    @Published var alertSignIn = false
    @Published var alertSignUp = false
    @Published var alertSuccessUp = false
    
    @Published var navigateChat = false
    
    @Published var viewChatOpen = true
    
    @Published var sideMenu = false
    @Published var rightMenuAnimate = false
    @Published var loadingImage = false
    

    
    let fireStoreDataBase = Firestore.firestore()
    private var documentID = ""
    
    
    //MARK: - AI features
    
    func sendMessage(message: String) {
        
        let userMessage = Message(content: message, isUser: true)
        
        DispatchQueue.main.async {
            self.messages.append(userMessage)
            self.getReply()
        }
    }
    
    
    func getReply() {
        
        let query = ChatQuery(messages: self.messages.map{.init(role: .user, content: $0.content)!}, model: .gpt3_5Turbo)
        
        openAI.chats(query: query) { result in
            
            switch result {
                
            case .success(let success):
                
                guard let choice = success.choices.first else {return}
                
                let message = choice.message.content?.string
                
                DispatchQueue.main.async {
                    self.messages.append(Message(content: message ?? "Error with the response", isUser: false))
                    
                }
                
            case .failure(let failure):
                
                print(failure.localizedDescription)
                
            }
        }
    }
    
    func sendImageMessage(prompt: String, number: Int? = 1) {
        loadingImage = true
        openAI.images(query: ImagesQuery(prompt: prompt, n: number, size: ._512)) { result in
            
            switch result {
                
            case .success(let image):
                print("success")
                
                DispatchQueue.main.async {
                    if let url = image.data.first?.url {
                        self.urlImage = url
                        self.loadingImage = false
                    }
                   
                }
                
            case .failure(let error):
                print(error)
                
                DispatchQueue.main.async {
                    self.loadingImage = false
                }
            }
        }
    }
    
    //MARK: - Sign methods
    
    
    func createUser(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error {
                self.signUp = .error
                print(error.localizedDescription)
                self.error = error.localizedDescription
                
                self.alertSignUp = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.alertSignUp = false
                }
            }
            
            if error == nil && result != nil  {
                
                self.signUp = .success
                self.navigateChat = true
                self.alertSuccessUp = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.alertSuccessUp = false
                }
                
                
            }
        }
    }
    
    func login(email: String, password: String) {
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error {
                print(error.localizedDescription)
                self.error = error.localizedDescription
                self.signIn = .error
                
                self.alertSignIn = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.alertSignIn = false
                }
            }
            
            if error == nil && result != nil {
                self.signIn = .success
                self.navigateChat = true
            }
        }
    }
    
    //MARK: - Saving image to library
    
    
    func saveImage(urlString: String) {
        
        guard let url = URL(string: urlString) else {
            print("url is empty")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _ , error in
            
            if let error {
                print(error.localizedDescription)
                self.errorDownloadImg = true
            }
            
            if error == nil && data != nil {
                
                if let data {
                    
                    self.errorDownloadImg = false
                    
                    if let image = UIImage(data: data) {
                        
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        
                        self.successDownloadImg = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.successDownloadImg = false
                        }
                    }
                }
            }
            
            
        }
        .resume()
    }
    
    //MARK: - Firebase save methods
    
    func uploadConversations() {
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        let firestorePost = ["Conversation" : messages.map {$0.dictionary}, "email" : currentUser.email ?? ""] as [String: Any]
        
        fireStoreDataBase.collection("Messages").addDocument(data: firestorePost) { error in
            
            if let error {
                print(error.localizedDescription)
                
            } else {
                print("success")
            }
        }
    }
    
    func deleteConversation() {
        
        if documentID != "" {
            fireStoreDataBase.collection("Messages").document(documentID).delete { error in
                if let error {
                    print(error.localizedDescription)
                } else {
                    print("delete succeed")
                }
            }
        } else {
            print("documentID is empty")
        }
    }
    
    func getConversations() {
        
        guard let currentUser = Auth.auth().currentUser else {return}
        
        fireStoreDataBase.collection("Messages").whereField("email", isEqualTo: currentUser.email!)
            .addSnapshotListener { snapshot, error in
                
                
            if let error  {
                print(error.localizedDescription)
            } else {
                
                if let snapshot {
                    
                    if snapshot.isEmpty == false  {
                        self.messagesArray.removeAll(keepingCapacity: false)

                        
                        for document in snapshot.documents {
                            self.documentID = document.documentID
                            
                            if let conversations = document.get("Conversation") as? [[String:Any]] {
                                for conversation in conversations {
                                    
                                    if let content = conversation["content"] as? String, let isUser = conversation["isUser"] as? Bool {
                                        let message = Message(content: content, isUser: isUser)
                                        
                                        DispatchQueue.main.async {
                                            self.messages.append(message)
                                        }
                                    }
                                }
                                
                            }
                        }
                        
                    } else {
                        print("empty message array in firebase")
                        DispatchQueue.main.async {
                            self.messages = []
                        }
                    }
                }
            }
        }
    }
    

    
}



