//
//  Pay.swift
//  DynamicDataDrivenApp
//
//  Created by Mladen Despotovic on 10.11.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation



class Pay: ApplicationServiceType {
    
    internal var serviceParameters: [String: Any] = [:]
    internal var service: [String: Any] = [:]
    var appRouter: ApplicationRouterType = ApplicationRouter()
    internal var scheme = "yourbank"
    
    var serviceName = ""
    

    
    required init?(jsonFilename: String?) {
        
        guard let filepath = Bundle.main.path(forResource: jsonFilename, ofType: "json"),
            let url = URL(string: filepath),
            let data = try? Data(contentsOf: url),
            let deserialised = try? JSONSerialization.jsonObject(with: data,
                                                               options: JSONSerialization.ReadingOptions.allowFragments),
            let serviceDictionary = deserialised as? [String: Any] else { return nil }
        
        self.service = serviceDictionary
    }
    
    func run() {

    }
    
}

extension Pay {
    
    func getOpenParameters(_ params: [String : Any]) -> (module: String,
                                                         method: String,
                                                         parameters: [String: String],
                                                         callback: [String: Any]?)? {
        
        guard params.count == 4,
            let module = params["##module"] as? String,
            let method = params["##method"] as? String,
            let parameters = params["##parameters"] as? [String : String] else { return nil }
        
        return (module, method, parameters, params["##callback"] as? [String: Any])
    }
    
    func callOpen(_ parameters: [String : Any]) {
        
        guard let (module,method,parameters,callback) = getOpenParameters(parameters),
            let url = URL(schema: scheme,
                          host: module,
                          path: method,
                          parameters: parameters) else { return }
        
        appRouter.open(url: url) { [weak self] (response, data, urlResponse, error) in
            
            if let callback = callback {
                self?.handleCallback(response: response,
                               urlResponse: urlResponse,
                               error: error,
                               callbackParameters: callback)
            }
        }
    }
    
    func handleCallback(response: [String : Any]?,
                        urlResponse: URLResponse?,
                        error: ResponseError?,
                        callbackParameters: [String : Any]) {
        
    }
    
    func callUrls(parameters: [String : Any]) {
        
        let urlKeysOnly = parameters.filter { $0.key == "%%url" }
        urlKeysOnly.forEach { (key, object) in
            
            
        }
    }
}

