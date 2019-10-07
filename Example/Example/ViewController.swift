//
//  ViewController.swift
//  Example
//
//  Created by Andriy Slyusar on 2019-10-05.
//  Copyright © 2019 Andriy Slyusar. All rights reserved.
//

import UIKit
import SwiftyKeychainKit

extension KeychainKeys {
  static let secret = KeychainKey<String>(key: "secret")
}

class ViewController: UIViewController {
  @IBOutlet weak var secretTextField: UITextField!

  let keychain = Keychain(service: "com.swifty.keychainkit.example")

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  @IBAction func didPressSaveButton(_ sender: Any) {
    guard let secret = secretTextField.text else {
      return
    }

    do {
      try keychain.set(secret, for: .secret)
    } catch {
      presentAlert(title: "Failed save to keychain", message: error.localizedDescription)
    }
  }

  @IBAction func didPressGetButton(_ sender: Any) {
    do {
      let value = try keychain.get(.secret)

      presentAlert(title: "Keychain value", message: value)
    } catch {
      presentAlert(title: "Failed get from keychain", message: error.localizedDescription)
    }
  }

  private func presentAlert(title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))

    self.present(alert, animated: true)
  }
}

