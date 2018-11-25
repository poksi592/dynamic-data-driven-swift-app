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
    var serviceName: String? {get}
    
    init?(jsonFilename: String)
    
    func loadService(jsonFilename: String) -> [String: Any]?
    func valid() -> Bool
    func run()
    
    mutating func callServiceRecursively(from array: [[String: Any]],
                                         response: [String: Any],
                                         service: () -> ()) 
}

extension ApplicationServiceType {
    
    var serviceName: String? {
        
        get {
            return service.keys.filter { $0.prefix(2) == "@@" }.first
        }
    }
    
    func valid() -> Bool {
        
        if service.count == 1,
            let key = service.first?.key ,
            key.prefix(2) == "@@" {
            
            return true
        }
        else { return false }
    }
    
    func loadService(jsonFilename: String) -> [String: Any]? {
        
        if let filepath = Bundle.main.path(forResource: jsonFilename, ofType: "json"),
            let url = URL(string: filepath),
            let data = try? Data(contentsOf: url),
            let deserialised = try? JSONSerialization.jsonObject(with: data,
                                                                 options: JSONSerialization.ReadingOptions.allowFragments),
            let serviceDictionary = deserialised as? [String: Any] {
            
            return serviceDictionary
        }
        else { return nil }
    }
    
    // Calls the service recursivelly again, if it finds it as dictionary in array passed.
    mutating func callServiceRecursively(from array: [[String: Any]],
                                         response: [String: Any],
                                         service: () -> ()) {
        
        guard let serviceName = self.serviceName,
            let parametersForService = ApplicationServiceParser.getParametersDictionaryForService(from: array,
                                                                                                  serviceName: serviceName) else { return }
        serviceParameters = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: parametersForService,
                                                                                         serviceParameters: serviceParameters,
                                                                                         response: response)
        service()
    }
    
    // Executes the elements within any array, which is representewd by a value of the dictionary with the key that starts with "%%response"
    // Every dictionary can have only one element
    func executeResponseParameterStatements(from array: [[String: Any]],
                                            response: [String: Any]) {
        
        
    }
    
    // Assign the values to "##..." service parameters
    mutating func assignValuesToServiceParameters(from array: [[String: Any]],
                                         response: [String: Any]) {
        
        let statementsWithResponsesOnly = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        guard let responseMatchingStatementsOnly = ApplicationServiceParser.getResponseMatchingStatements(from: statementsWithResponsesOnly,
                                                                                                          response: response) else { return }
        responseMatchingStatementsOnly.forEach { responseMatchingStatement in
            
            guard let key = responseMatchingStatement.keys.first,
                let value = responseMatchingStatement[key] as? [String: Any] else { return }
            serviceParameters = ApplicationServiceParser.getResponseUpdatedServiceParameters(from: value,
                                                                                             serviceParameters: serviceParameters,
                                                                                             response: response)
        }
    }
    
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
    
    class func getStatementsWithResponsesOnly(from array: [[String: Any]]) -> [[String: Any]] {
        
        let responseStatements = array.filter { $0.count == 1}.filter { $0.first?.key.prefix(10) == "%%response" }
        let matchingResponseStatements = responseStatements.filter { response in

            if response["%%response"] != nil { return true }
            
            guard let responseComponents = response.keys.first?.split(separator: ","),
                    responseStatements.count > 0 else { return false }
            let responseMatchingKeys = responseComponents.filter { $0.prefix(10) == "%%response" }
            guard responseMatchingKeys.count > 0 else { return false }
            
            return true
        }
        return matchingResponseStatements
    }
    
    // Get back only statements that havbe the reponses and they are matching repsonses from parameter dictionary
    class func getResponseMatchingStatements(from array: [[String: Any]],
                                             response: [String: Any]) -> [[String: Any]]? {
        
        let responseStatements = ApplicationServiceParser.getStatementsWithResponsesOnly(from: array)
        
        let matchingResponseStatements = responseStatements.filter { responseDict in
            
            if responseDict["%%response"] != nil { return true }
            
            guard let responseComponents = responseDict.keys.first?.split(separator: ","),
                responseStatements.count > 0 else { return false }
            
            let keysFromResponseComponents = responseComponents.map { (responseComponent) -> String? in
                
                let responseSeparatedComponents = responseComponent.split(separator: ".")
                guard responseSeparatedComponents.count > 1,
                    let key = responseSeparatedComponents.last else { return nil }
                
                return String(key)
            }.compactMap { $0 }
            
            for key in keysFromResponseComponents {
                
                if response[key] == nil {
                    return false
                }
            }
            
            return true
        }
        
        return matchingResponseStatements
    }
}
