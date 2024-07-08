//
//  Created by Andriy Slyusar on 2024-07-07.
//  Copyright © 2024 Andriy Slyusar. All rights reserved.
//

import Foundation
import SwiftUI
import SwiftyKeychainKit

struct SwiftUICaseStudyView: View {
    @AppKeychainStorage(.secret) var secret
//    @AppKeychainStorage(.secret, keychain: .accessGroupKeychain) var secret

    @State var secretInput: String = ""

    @State private var isDisplaySecretAlert = false
    @State private var isDisplaySaveErrorAlert = false
    @State private var isDisplayRemoveErrorAlert = false

    @State private var saveError: Error?
    @State private var removeError: Error?

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 8) {
                TextField("Input secret", text: $secretInput)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)

                Button("Save") {
                    do {
                        try self._secret.set(secretInput)
                        secretInput = ""
                    } catch {
                        isDisplaySaveErrorAlert = true
                        saveError = error
                    }
                }
                .alert("Failed to save", isPresented: $isDisplaySaveErrorAlert, presenting: saveError) { _ in
                    Button("OK", role: .cancel) {}
                } message: { error in
                    Text(error.localizedDescription)
                }

                Button("Remove") {
                    do {
                        try self._secret.remove()
                    } catch {
                        isDisplayRemoveErrorAlert = true
                        removeError = error
                    }
                }
                .alert("Failed to remove", isPresented: $isDisplayRemoveErrorAlert, presenting: removeError) { _ in
                    Button("OK", role: .cancel) {}
                } message: { error in
                    Text(error.localizedDescription)
                }
            }

            Button("Get secret") {
                isDisplaySecretAlert = true
            }
            .alert("Secret", isPresented: $isDisplaySecretAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                switch secret {
                    case .success(let value):
                        if let value = value {
                            Text("Keychain value: \(value)")
                        } else {
                            Text("Keychain missing value")
                        }
                    case .failure(let error):
                        Text("Keychain error: \(error)")
                }
            }

            switch secret {
                case .success(let value):
                    if let value = value {
                        Text("Keychain value: \(value)")
                    } else {
                        Text("Keychain missing value")
                    }

                case .failure(let error):
                    Text("Keychain error: \(error)")
            }
        }
    }
}
