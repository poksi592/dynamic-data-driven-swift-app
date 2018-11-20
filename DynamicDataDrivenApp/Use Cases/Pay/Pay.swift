//
//  Pay.swift
//  DynamicDataDrivenApp
//
//  Created by Mladen Despotovic on 10.11.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

enum ReservedKeyword: String {
    
    case serviceParameters = "serviceParameters"
    case execute = "execute"
    case open = "open"
    case module = "module"
    case method = "method"
    case parameters = "parameters"
    case callback = "callback"
    case error = "error"
    case response = "response.paymentToken"
}

enum ValueType {
    
    case none
    case int
    case float
    case double
    case string
    case dictionary
    case array
    
    init?(_ value: Any) {
        
        switch value {
        case is Int:
            self = .int
        case is Float:
            self = .float
        case is Double:
            self = .double
        case is String:
            self = .string
        case is Dictionary<String,Any>:
            self = .dictionary
        case is Array<Any>:
            self = .array
        default:
            self = .none
        }
    }
    
    var isNumber: Bool {
        return [.int, .float, .double].contains(self)
    }
    var isValue: Bool {
        return [.int, .float, .double, .string].contains(self)
    }
}


class Pay: ApplicationServiceType {
    
    internal var serviceParameters: [String: Any] = [:]
    internal var service: [String: Any] = [:]
    var appRouter: ApplicationRouterType = ApplicationRouter()
    internal var scheme = "yourbank"
    
    var serviceName = ""
    

    
    required init?(jsonFilename: String) {
        
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
    
    func valid() -> Bool {
        
        if service.count == 1,
            let key = service.first?.key ,
            key.prefix(2) == "@@" {
            
            return true
        }
        else { return false }
    }
    
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
    
    func parse(array: [String: Any]) {
        
        let parameterKeys = array.keys.filter { $0.prefix(2) == "##" }
        
    }
    
    
}

