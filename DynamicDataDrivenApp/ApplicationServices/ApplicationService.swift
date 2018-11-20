//
//  ApplicationService.swift
//  DynamicDataDrivenApp
//
//  Created by Mladen Despotovic on 11.11.18.
//  Copyright © 2018 Mladen Despotovic. All rights reserved.
//

import Foundation

/**
 ApplicationServiceType instance represents execution of one single Use Case.
 It's based on execution steps from JSON file, which is passed by initialisation.
 */

protocol ApplicationServiceType {
    
    var serviceParameters: [String: Any] {get set}
    var service: [String: Any] {get set}
    var appRouter: ApplicationRouterType {get set}
    var scheme: String {get set}
    
    init?(jsonFilename: String)
    
    func valid() -> Bool
    func run()
}

class ApplicationServiceParser {
    
    class func getParametersDictionaryForService(from array: [[String: Any]],
                                                 serviceName: String) -> [String: Any]? {
    
        // Isolate the dictionary under '@@...' service name as a key
        guard let serviceDictionary = array.reduce([String: Any](), { (current, dict) -> [String: Any]? in
            
            guard dict.count == 1,
                let serviceDict = dict.first?.key,
                serviceDict == serviceName else {
                    return nil
            }
            return dict[serviceName] as? [String: Any]
            
        }) else { return nil }
        
        let parametersDictionaryOnly = serviceDictionary.filter({ $0.key.prefix(2) == "##" })
        
        return parametersDictionaryOnly.count > 0 ? parametersDictionaryOnly : nil
    }
    
    class func getResponseUpdatedServiceParameters(from parametersDictionary: [String: Any],
                                                   serviceParameters: [String: Any],
                                                   response: [String: Any]) -> [String: Any] {
        
        guard parametersDictionary.count > 0,
                serviceParameters.count > 0,
                response.count > 0 else { return serviceParameters }
        
        // Create new parameters dictionary with values which correspond to values from 'response' dictionary
        var newServiceParameters = serviceParameters
        parametersDictionary.forEach { key, value in
            
            guard let stringValue = value as? String else { return }
            let valueSplits = stringValue.split(separator: ".")
            
            if ValueType(value)?.isNumber == true {
                newServiceParameters[key] = value
            }
            else if valueSplits.first == "%%response" && valueSplits.count == 2  {
                
                newServiceParameters[key] = response[String(valueSplits.last!)]
            }
        }
        
        return newServiceParameters
    }
}
