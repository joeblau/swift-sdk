//
//  VerifyEmailView.swift
//  swift-example
//
//  Created by Brian Corbin on 6/4/24.
//

import SwiftUI
import CapsuleSwift

struct VerifyEmailView: View {
    
    @EnvironmentObject var capsule: CapsuleSwift.Capsule
    
    let email: String
    
    @State private var code = ""
    @Binding var path: [NavigationDestination]
    
    @Environment(\.authorizationController) private var authorizationController
        
    var body: some View {
        TextField("Code", text: $code)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .border(.secondary)
        Button("Verify") {
            Task.init {
                let biometricsId = try! await capsule.verify(verificationCode: code)
                try! await capsule.generatePasskey(email: email, biometricsId: biometricsId, authorizationController: authorizationController)
                path.append(.wallet)
                try! await capsule.createWallet(skipDistributable: false)
            }
        }
    }
}

#Preview {
    VerifyEmailView(email: "", path: .constant([]))
}