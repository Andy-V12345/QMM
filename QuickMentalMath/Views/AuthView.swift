//
//  AuthView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/6/24.
//

import SwiftUI

enum AuthMode {
    case LOGIN, SIGNUP
}

enum ViewState {
    case DEFAULT, LOADING, ERROR
}

func validateEmail(email: String) -> Bool {
    if email.count > 100 {
        return false
    }
    let emailFormat = "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: email)
}

struct AuthView: View {
    
    @State var email = ""
    @State var password = ""
    @State var usernameText = ""
    @State var authMode: AuthMode = .LOGIN
    @State var authViewState: ViewState = .DEFAULT
    
    @State var errorTitle = ""
    @State var errorMsg = ""
    @State var showError = false
    
    @State var displayForgotPassword = false
    
    @FocusState var isEmailFocused: Bool
    @FocusState var isPasswordFocused: Bool
    @FocusState var isUsernameFocused: Bool
    
    @EnvironmentObject var authInfo: AuthInfo
    @EnvironmentObject var appModel: AppModel
    
    @Namespace var namespace
    
    @AppStorage("authState") var authState: AuthState = .UNAUTHORIZED
    @AppStorage("jwtToken") var jwtToken = ""
    @AppStorage("username") var username = ""
    @AppStorage("id") var id = 0

    
    var body: some View {
        GeometryReader { metrics in
                        
            ZStack {
                
                Color.white.ignoresSafeArea()
                    .onTapGesture {
                        isEmailFocused = false
                        isPasswordFocused = false
                        isUsernameFocused = false
                    }
                
                VStack(spacing: 40) {
                                
                    VStack(spacing: 45) {
                        
                        VStack {
                            
                            Text(authMode == .LOGIN ? "Sign In" : "Sign Up")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundStyle(Color("darkPurple"))
                            
                            Text("Please sign in to continue")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.body)
                                .foregroundStyle(Color("lightPurple"))
                                .bold()
                        } //: Text VStack
                        
                        VStack(spacing: 35) { // TextFields VSTack
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .bold()
                                
                                TextField(text: $email, prompt: Text("Email").fontWeight(.regular), label: {
                                    Text(email)
                                })
                                .foregroundStyle(.black)
                                .bold()
                                .padding(.vertical, 15)
                                .focused($isEmailFocused)
                            }
                            .foregroundStyle(.gray)
                            .overlay(
                                Divider()
                                    .padding(.vertical, 0)
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .background(Color("darkPurple")),
                                alignment: .bottom
                            )
                            
                            if (authMode == .SIGNUP) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person")
                                        .bold()
                                    
                                    TextField(text: $usernameText, prompt: Text("Username").fontWeight(.regular), label: {
                                        Text(usernameText)
                                    })
                                    .foregroundStyle(.black)
                                    .bold()
                                    .padding(.vertical, 15)
                                    .focused($isUsernameFocused)
                                    
                                }
                                .foregroundStyle(.gray)
                                .overlay(
                                    Divider()
                                        .padding(.vertical, 0)
                                        .frame(maxWidth: .infinity, maxHeight: 1)
                                        .background(Color("darkPurple")),
                                    alignment: .bottom
                                )
                            }
                                                
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .bold()
                                
                                SecureField(text: $password, prompt: Text("Password").fontWeight(.regular), label: {
                                    Text(password)
                                })
                                .foregroundStyle(.black)
                                .bold()
                                .padding(.vertical, 15)
                                .focused($isPasswordFocused)
                                
                                Button(action: {
                                    displayForgotPassword = true
                                }, label: {
                                    Text("FORGOT")
                                        .font(.caption)
                                        .fontWeight(.heavy)
                                        .foregroundStyle(Color("lightPurple"))
                                })
                                .opacity(authMode == .SIGNUP ? 0.3 : 1)
                                .disabled(authMode == .SIGNUP)
                            }
                            .foregroundStyle(.gray)
                            .overlay(
                                Divider()
                                    .padding(.vertical, 0)
                                    .frame(maxWidth: .infinity, maxHeight: 1)
                                    .background(Color("darkPurple")),
                                alignment: .bottom
                            )
                            .matchedGeometryEffect(id: "passwordField", in: namespace)
                            
                            
                        } //: TextFields VStack
                        
                        HStack { // Continue button
                            Spacer()
                            
                            Button(action: {
                                authViewState = .LOADING
                                
                                if authMode == .LOGIN {
                                    if validateEmail(email: email) {
                                        Task {
                                            let res = await authInfo.login(email: email, password: password)
                                            if res == "INVALID_CREDS"  {
                                                errorTitle = "Invalid credentials"
                                                errorMsg = "The email and password you entered were incorrect. Please try again!"
                                                authViewState = .ERROR
                                            }
                                            else if res == "ERROR_DECODING" || res == "UNKNOWN_ERROR" {
                                                errorTitle = "Error signing in"
                                                errorMsg = "Something went wrong on our end. Please try again!"
                                                authViewState = .ERROR
                                            }
                                            else {
                                                jwtToken = authInfo.user!.jwtToken
                                                username = authInfo.user!.username
                                                id = authInfo.user!.id
                                                authState = .AUTHORIZED
                                                authViewState = .DEFAULT
                                                
                                                email = ""
                                                password = ""
                                                usernameText = ""
                                                
                                                appModel.path.append(authState)
                                            }
                                        }
                                    }
                                    else {
                                        errorTitle = "Invalid email"
                                        errorMsg = "Please enter a valid email."
                                        authViewState = .ERROR
                                    }
                                }
                                else {
                                    if validateEmail(email: email) {
                                        Task {
                                            let res = await authInfo.signUp(email: email, username: usernameText, password: password)
                                            
                                            if res == "EMAIL_TAKEN" {
                                                errorTitle = "Error signing up"
                                                errorMsg = "The email you entered is already taken. Please use another one!"
                                                authViewState = .ERROR
                                            }
                                            else if res == "USERNAME_TAKEN" {
                                                errorTitle = "Error signing up"
                                                errorMsg = "The username you entered is already taken. Please use another one!"
                                                authViewState = .ERROR
                                            }
                                            else if res == "INVALID_PASSWORD" {
                                                errorTitle = "Error signing up"
                                                errorMsg = "The password you entered is too short. Passwords must be at least 6 characters long."
                                                authViewState = .ERROR
                                            }
                                            else if res == "UNKNOWN_ERROR" {
                                                errorTitle = "Error signing up"
                                                errorMsg = "Something went wrong on our end. Please try again!"
                                                authViewState = .ERROR
                                            }
                                            else {
                                                jwtToken = authInfo.user!.jwtToken
                                                username = authInfo.user!.username
                                                id = authInfo.user!.id
                                                authState = .AUTHORIZED
                                                authViewState = .DEFAULT
                                                
                                                email = ""
                                                password = ""
                                                usernameText = ""
                                                
                                                appModel.path.append(authState)
                                            }
                                        }
                                    }
                                    else {
                                        errorTitle = "Invalid email"
                                        errorMsg = "Please enter a valid email."
                                        authViewState = .ERROR
                                    }
                                }
                            }, label: {
                                HStack {
                                    if authViewState == .DEFAULT || authViewState == .ERROR {
                                        Text("CONTINUE")
                                            .font(.subheadline)
                                            .fontWeight(.heavy)
                                        
                                        Image(systemName: "arrow.right")
                                    }
                                    else if authViewState == .LOADING {
                                        LoadingSpinner(size: 15, color: Color.white, width: 3)
                                    }
                                }
                            })
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.vertical, 16)
                            .frame(width: 160)
                            .background(
                                Capsule().fill(Color("lighterPurple"))
                                    .shadow(color: Color("lightPurple"), radius: 6, y: 2)
                            )
                            .disabled(authViewState == .LOADING || ((authMode == .SIGNUP && usernameText.isEmpty) || email.isEmpty || password.isEmpty))
                            .opacity(authViewState == .LOADING || ((authMode == .SIGNUP && usernameText.isEmpty) || email.isEmpty || password.isEmpty) ? 0.5 : 1)
                            .matchedGeometryEffect(id: "button", in: namespace)
                           
                        } //: HStack
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 15) {
                        HStack { // Don't have an account button
                            Spacer()
                            
                            Text(authMode == .LOGIN ? "Don't have an account?" : "Already have an account?")
                                .foregroundStyle(Color.gray)
                            
                            Button(action: {
                                withAnimation(.spring(duration: 0.4, bounce: 0.45)) {
                                    authMode = authMode == .LOGIN ? .SIGNUP : .LOGIN
                                    email = ""
                                    usernameText = ""
                                    password = ""
                                }
                            }, label: {
                                Text(authMode == .LOGIN ? "Create one" : "Sign in")
                            })
                            .foregroundStyle(Color("lightPurple"))
                            
                            
                            Spacer()
                        } //: Switch to Sign Up HStack
                        .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Divider()
                                    .overlay(Color("darkPurple"))
                            }
                            
                            Text("or")
                                .italic()
                                .foregroundStyle(.gray)
                            
                            VStack {
                                Divider()
                                    .overlay(Color("darkPurple"))
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: {
                            authInfo.authState = .NO_ACCOUNT
                            authState = .NO_ACCOUNT
                            
                            appModel.path.append(authState)
                        }, label: {
                            HStack {
                                Text("Continue without an account")
                                
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(Color("lightPurple"))
                            .fontWeight(.bold)
                        })
                        
                    }
                    .font(.subheadline)
                    
                } //: Parent VStack
                .padding(.top, 80)
                .padding(.bottom, 20)
                .padding(.horizontal, 35)
                
            } //: ZStack
            .disabled(authViewState == .LOADING)
            .onChange(of: authViewState, perform: { value in
                if value == .ERROR {
                    showError = true
                }
                else {
                    showError = false
                }
            })
            .alert(errorTitle, isPresented: $showError, actions: {
                Button(role: .cancel, action: {
                    authViewState = .DEFAULT
                }, label: {
                    Text("Ok")
                })
            }, message: {
                if !errorMsg.isEmpty {
                    Text(errorMsg)
                }
            })
            .fullScreenCover(isPresented: $displayForgotPassword, content: {
                ForgotPasswordView()
            })
        }
        .ignoresSafeArea(.keyboard)
    }
    
}

#Preview {
    AuthView()
        .environmentObject(AuthInfo())
}
