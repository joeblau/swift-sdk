import SwiftUI
import CapsuleSwift

struct EmailAuthView: View {
    @EnvironmentObject var capsuleManager: CapsuleManager
    @EnvironmentObject var appRootManager: AppRootManager

    @State private var email = ""
    @State private var shouldNavigateToVerifyEmail = false
    
    // New states for error handling and loading
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.authorizationController) private var authorizationController
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your email address to create or log in with a passkey.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextField("Email Address", text: $email)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if isLoading {
                ProgressView("Processing...")
            }
            
            Button {
                guard !email.isEmpty else {
                    errorMessage = "Please enter an email address."
                    return
                }
                isLoading = true
                errorMessage = nil
                Task {
                    do {
                        let userExists = try await capsuleManager.checkIfUserExists(email: email)
                        if userExists {
                            // User already exists, let them proceed to login (or show a message)
                            // For now, we just show an error encouraging them to log in instead.
                            errorMessage = "User already exists. Please log in with passkey."
                            isLoading = false
                        } else {
                            try await capsuleManager.createUser(email: email)
                            isLoading = false
                            shouldNavigateToVerifyEmail = true
                        }
                    } catch {
                        errorMessage = "Failed to create user: \(error.localizedDescription)"
                        isLoading = false
                    }
                }
            } label: {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || email.isEmpty)
            .padding(.horizontal)
            .navigationDestination(isPresented: $shouldNavigateToVerifyEmail) {
                VerifyEmailView(email: email)
                    .environmentObject(capsuleManager)
                    .environmentObject(appRootManager)
            }
            
            HStack {
                Rectangle().frame(height: 1)
                Text("Or")
                Rectangle().frame(height: 1)
            }.padding(.vertical)
            
            Button {
                Task.init {
                    try await capsuleManager.login(authorizationController: authorizationController)
                    appRootManager.currentRoot = .home
                }
            } label: {
                Text("Log In with Passkey")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            
            Spacer()
            
        }
        .padding()
        .navigationTitle("Email + Passkey")
    }
}
