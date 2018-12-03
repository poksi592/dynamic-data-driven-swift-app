//
//  LoginViewController.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 29.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: StoryboardIdentifiableViewController {
    
    var presenter: LoginPresenter?
    
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var passwordField: UITextField?
    
    @IBAction private func login(_ sender: UIButton) {

        self.dismiss(animated: true, completion: { [weak self] in
            self?.presenter?.login(username: self?.usernameField?.text,
                                   password: self?.passwordField?.text)
        })
    }
}
