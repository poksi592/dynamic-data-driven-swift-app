//
//  PaymentsPresenter.swift
//  ModuleArchitectureDemo
//
//  Created by Mladen Despotovic on 28.06.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation
import UIKit

class PaymentsPresenter: ModuleRoutable, ModulePresentable {
    
    lazy private var wireframe = PaymentWireframe()
    lazy private var interactor = PaymentsInteractor()
    private var parameters: ModuleParameters?
    private var callback: ModuleCallback?
    
    required init() {}
    
    static func routable() -> ModuleRoutable {
        return self.init()
    }
    
    static func getPaths() -> [String] {
        return ["/pay",
                "/refund",
                "/refund-alert-only"]
    }
    
    func route(parameters: ModuleParameters?, path: String?, callback: ModuleCallback?) {
        
        guard let path = path else { return }
        self.parameters = parameters
        self.callback = callback
        
        switch path {
        case "/refund":
            wireframe.presentViewController(ofType: RefundSentViewController.self,
                                            presenter: self,
                                            parameters: parameters)
        case "/refund-alert-only":
            let alertMessage = UIAlertController(title: "Refund Request sent!",
                                                 message: nil,
                                                 preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            wireframe.presentationMode = .modal
            wireframe.present(viewController: alertMessage)
        default:
            wireframe.presentViewController(ofType: PaymentsViewController.self,
                                            presenter: self,
                                            parameters: parameters)
        }
    }
    
    
    func pay(amount: String?) {
        
        if let amount = amount {
            parameters?[PaymentsModuleParameters.suggestedAmount.rawValue] = amount
            interactor.pay(parameters: parameters) { [weak self] (response, error) in
                
                self?.callback?(nil, nil, response, error)
            }
        }
    }
}
