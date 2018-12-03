//
//  RefundSentViewController.swift
//  DynamicDataDrivenApp
//
//  Created by Mladen Despotovic on 03.12.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class RefundSentViewController: UIViewController, RoutableViewControllerType {
    
    var presenter: ModulePresentable?
    
    @IBAction private func oKButtonAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
