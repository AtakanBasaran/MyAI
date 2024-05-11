//
//  ContentView.swift
//  MyAI
//
//  Created by Atakan Başaran on 11.05.2024.
//

import SwiftUI
import AuthenticationServices

struct SignView: View {
    
    @EnvironmentObject var vm: ViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState var dismissKeyboard: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var alertSignIn = false
    @State private var alertSignUp = false
    @State private var alertEmpty = false
    
    
    
    var body: some View {
        
        
        NavigationStack {
            
            GeometryReader { geo in
                
                
                ZStack {
                    
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if dismissKeyboard {
                                dismissKeyboard = false
                            }
                        }
                    
                    
                    
                    VStack(spacing: 90) {
                        
                        HStack {
                            
                            Image(systemName: "bonjour")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .font(.system(size: 50))
                                
                            
                            Text("MyAI")
                                .foregroundStyle(colorScheme == .dark ? .white : .black)
                                .font(.system(.title))
                                .bold()
                                
                            
                        }
                        .padding(.top, 50)
                        
                        
                        VStack(spacing: 20) {
                            
                            HStack {
                                
                                Image(systemName: "person.crop.circle")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(.system(size: 25))
                                
                                
                                TextField("Email", text: $email, axis: .vertical)
                                    .keyboardType(.emailAddress)
                                    .textInputAutocapitalization(.never)
                                    .submitLabel(.next)
                                    .focused($dismissKeyboard)
                                    .frame(width: geo.size.width * 0.7)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 15))

                            }
                            
                            
                            HStack {
                                
                               Image(systemName: "lock.circle")
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .font(.system(size: 25))
                                
                                SecureField("Password", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .focused($dismissKeyboard)
                                    .submitLabel(.done)
                                    .frame(width: geo.size.width * 0.7)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.1))
                                    .clipShape(.rect(cornerRadius: 15))
                            }
                        }
                        
                        
                        
                        VStack(spacing: 20) {
                            
                            Button(action: {
                                
                                if email != "" && password != "" {
                                    vm.login(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines))
                                } else {
                                    self.alertEmpty = true
                                }
                            }, label: {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 280, height: 40)
                                        .foregroundStyle(.pink)
                                    
                                    Text("Sign In")
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                    
                                }
                            })
                            
                            
                            Button(action: {
                                if email != "" && password != "" {
                                    vm.createUser(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines))
                                    
                                } else {
                                    self.alertEmpty = true
                                }
                                
                            }, label: {
                                
                                ZStack {
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 280, height: 40)
                                        .foregroundStyle(.cyan)
                                    
                                    Text("Sign Up")
                                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                                }
                            })
                            
                            
                        }
                        .padding(.top, 30)
                        
                        Spacer()
                        
 
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                
            }
            .ignoresSafeArea(.keyboard)
            .navigationDestination(isPresented: $vm.navigateChat) {
                ChatBotView()
            }
        }
        .ignoresSafeArea(.keyboard)
    
        .onChange(of: vm.signUp) { _ in
            
            if vm.signUp == .success {
                vm.navigateChat = true
            }
        }
        
        .onChange(of: vm.signIn) { _ in
            
            if vm.signIn == .success {
                vm.navigateChat = true
            }
        }
        
        .alert("Error!", isPresented: $vm.alertSignUp) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(vm.error)
        }
        
        .alert("Error!", isPresented: $vm.alertSignIn) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text(vm.error)
        }
        
        .alert("Error!", isPresented: $alertEmpty) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Email and password cannot be empty")
        }
        
        
    }
}


#Preview {
    SignView()
}
