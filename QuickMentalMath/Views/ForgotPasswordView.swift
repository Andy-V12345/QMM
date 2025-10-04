//
//  ForgotPasswordView.swift
//  QuickMentalMath
//
//  Created by Andy Vu on 7/15/24.
//

import SwiftUI

enum ForgotPasswordState {
    case SEND, VERIFY, RESET
}

struct ForgotPasswordView: View {
    
    let buttonHeight: CGFloat = 50
    let buttonCornerRadius: CGFloat = 10
    let buttonShadowOffset: CGFloat = 6
    
    @State var email: String = ""
    @State var token: String = ""
    @State var password: String = ""
    @State var viewState: ViewState = .DEFAULT
    @State var showError = false
    @State var errorMsg = ""
    @State var errorTitle = ""
    @State var showDoneAlert = false
    
    @FocusState var isEmailFocused: Bool
    @FocusState var isTokenFocused: Bool
    @FocusState var isPasswordFocused: Bool
    
    
    @State var forgotPasswordState: ForgotPasswordState = .SEND
    
    @EnvironmentObject var authInfo: AuthInfoModel
    
    @Environment(\.dismiss) var dismiss
    
    func handleSendLink() {
        if validateEmail(email: email) {
            viewState = .LOADING
            
            Task {
                let success = await authInfo.sendEmail(email: email)
                if success {
                    viewState = .DEFAULT
                    forgotPasswordState = .VERIFY
                }
                else {
                    viewState = .ERROR
                    errorTitle = "Invalid email"
                    errorMsg = "We couldn't find a user with that email!"
                }
            }
            
        }
        else {
            viewState = .ERROR
            errorTitle = "Invalid email"
            errorMsg = "Please enter a valid email."
        }
    }
    
    func handleVerifyCode() {
        viewState = .LOADING
        
        Task {
            let isValid = await authInfo.verifyToken(token: token)
            
            if isValid {
                viewState = .DEFAULT
                forgotPasswordState = .RESET
            }
            else {
                viewState = .ERROR
                errorTitle = "Invalid token"
                errorMsg = "The token you entered is not valid. Please double-check it."
            }
        }
    }
    
    func handleResetPassword() {
        viewState = .LOADING
        
        Task {
            let result = await authInfo.resetPassword(token: token, password: password)
            
            if result == "PASSWORD_UPDATED" {
                viewState = .DEFAULT
                showDoneAlert = true
            }
            else if result == "INVALID_PASSWORD_LENGTH" {
                viewState = .ERROR
                errorTitle = "Invalid password"
                errorMsg = "The password you entered is too short. It must be at least 6 characters."
            }
            else {
                viewState = .ERROR
                errorTitle = "Error"
                errorMsg = "Something went wrong with resetting your password! Please try again."
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(edges: .all)
                .onTapGesture {
                    isEmailFocused = false
                    isTokenFocused = false
                    isPasswordFocused = false
                }
            
            VStack {
                Spacer()
                
                if forgotPasswordState == .SEND {
                    VStack(spacing: 40) {
                        VStack(spacing: 20) {
                            Text("forgot password")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                            Text("enter your email and we'll send you a verification code.")
                                .foregroundColor(Color("lightPurple"))
                                .frame(width: 300)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .bold()
                                
                                TextField(text: $email, prompt: Text("email").fontWeight(.regular), label: {
                                    Text(email)
                                })
                                .foregroundStyle(.black)
                                .bold()
                                .padding(.vertical, 15)
                                .focused($isEmailFocused)
                                .disabled(viewState == .LOADING)
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
                        
                        Button(action: {}, label: {
                            if viewState == .LOADING {
                                LoadingSpinner(size: 15, color: Color.white, width: 3)
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                            }
                            else {
                                Text("send link")
                                    .foregroundColor(Color("darkPurple"))
                                    .font(.title2)
                                    .bold()
                                
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .raisedButton(cornerRadius: buttonCornerRadius, shadowOffset: buttonShadowOffset, action: {
                            handleSendLink()
                        })
                        .disabled(viewState == .LOADING || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(viewState == .LOADING || email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    }
                }
                else if forgotPasswordState == .VERIFY {
                    VStack(spacing: 40) {
                        VStack(spacing: 20) {
                            Text("verify code")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                            Text("enter the verification code we sent to your email.")
                                .foregroundColor(Color("lightPurple"))
                                .frame(width: 300)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal")
                                    .bold()
                                
                                TextField(text: $token, prompt: Text("verification code").fontWeight(.regular), label: {
                                    Text(token)
                                })
                                .foregroundStyle(.black)
                                .bold()
                                .padding(.vertical, 15)
                                .focused($isTokenFocused)
                                .disabled(viewState == .LOADING)
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
                        
                        Button(action: {}, label: {
                            if viewState == .LOADING {
                                LoadingSpinner(size: 15, color: Color.white, width: 3)
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                            }
                            else {
                                Text("verify token")
                                    .foregroundColor(Color("darkPurple"))
                                    .font(.title2)
                                    .bold()
                                
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .raisedButton(cornerRadius: buttonCornerRadius, shadowOffset: buttonShadowOffset, action: {
                            handleVerifyCode()
                        })
                        .disabled(viewState == .LOADING || token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(viewState == .LOADING || token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                        
                    }
                }
                else {
                    VStack(spacing: 40) {
                        VStack(spacing: 20) {
                            Text("reset password")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("darkPurple"))
                            Text("enter your new password. it must be at least 6 characters.")
                                .foregroundColor(Color("lightPurple"))
                                .frame(width: 300)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .bold()
                                
                                SecureField(text: $password, prompt: Text("new password").fontWeight(.regular), label: {
                                    Text(password)
                                })
                                .foregroundStyle(.black)
                                .bold()
                                .padding(.vertical, 15)
                                .focused($isPasswordFocused)
                                .disabled(viewState == .LOADING)
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
                        
                        Button(action: {}, label: {
                            if viewState == .LOADING {
                                LoadingSpinner(size: 15, color: Color.white, width: 3)
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                            }
                            else {
                                Text("reset password")
                                    .foregroundColor(Color("darkPurple"))
                                    .font(.title2)
                                    .bold()
                                
                            }
                        })
                        .frame(maxWidth: .infinity)
                        .frame(height: buttonHeight)
                        .raisedButton(cornerRadius: buttonCornerRadius, shadowOffset: buttonShadowOffset, action: {
                            handleResetPassword()
                        })
                        .disabled(viewState == .LOADING || password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(viewState == .LOADING || password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }, label: {
                    Text("cancel")
                        .font(.headline)
                        .foregroundStyle(Color("lightPurple"))
                })
            } //: VStack
            .padding(.horizontal, 40)
            .padding(.bottom, 15)
            
            .onChange(of: viewState, perform: { new in
                if new == .ERROR {
                    showError = true
                }
                else {
                    showError = false
                }
            })
            .alert(errorTitle, isPresented: $showError, actions: {
                Button(role: .cancel, action: {
                    viewState = .DEFAULT
                }, label: {
                    Text("Ok")
                })
            }, message: {
                if !errorMsg.isEmpty {
                    Text(errorMsg)
                }
            })
            .alert("Done", isPresented: $showDoneAlert, actions: {
                Button(role: .cancel, action: {
                    dismiss()
                }, label: {
                    Text("Ok")
                })
            }, message: {
                Text("Your password has been reset!")
            })
        } //: ZStack
    }
}

#Preview {
    ForgotPasswordView()
}
