//
//  SaveXml.swift
//  jamf-migrator
//
//  Created by Leslie Helou on 6/28/18.
//  Copyright © 2018 jamf. All rights reserved.
//

import Foundation

class Xml {
    let vc = ViewController()
    let fm = FileManager()
    let baseXmlFolder = NSHomeDirectory() + "/Documents/Jamf Migrator"
    var saveXmlFolder = ""
    var endpointPath  = ""
    
    
    func save(node: String, xml: String, name: String, id: Int, format: String, debug: Bool) {
        
        if debug { ViewController().writeToLog(stringOfText: "[saveXML] saving \(name), format: \(format), to folder \(node)\n") }
        // Create folder to store xml files if needed - start
        saveXmlFolder = baseXmlFolder+"/"+format
        if !(fm.fileExists(atPath: saveXmlFolder)) {
            do {
                try fm.createDirectory(atPath: saveXmlFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                if debug { vc.writeToLog(stringOfText: "Problem creating \(saveXmlFolder) folder: Error \(error)\n") }
                return
            }
        }
        // Create folder to store xml files if needed - end
        
        // Create endpoint type to store xml files if needed - start
        switch node {
        case "selfservicepolicyicon", "macapplicationsicon", "mobiledeviceapplicationsicon":
            endpointPath = saveXmlFolder+"/"+node+"/\(id)"
        default:
            endpointPath = saveXmlFolder+"/"+node
        }
        if !(fm.fileExists(atPath: endpointPath)) {
            do {
                try fm.createDirectory(atPath: endpointPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                if debug { vc.writeToLog(stringOfText: "Problem creating \(endpointPath) folder: Error \(error)\n") }
                return
            }
        }
        // Create endpoint type to store xml files if needed - end
        
        switch node {
        case "selfservicepolicyicon", "macapplicationsicon", "mobiledeviceapplicationsicon":
            
            let iconSource = "\(xml)"
            let iconDest   = "\(endpointPath)/\(name)"

//            print("copy from \(iconSource) to: \(iconDest)")
            do {
                try fm.copyItem(atPath: iconSource, toPath: iconDest)
//                print("Copied \(iconSource) to: \(iconDest)")
            } catch {
//                print("Problem copying \(iconSource) to: \(iconDest)")
                if debug { vc.writeToLog(stringOfText: "Problem copying \(iconSource) to: \(iconDest)\n") }
            }
        default:
            let xmlFile = "\(name)-\(id).xml"
            if let xmlDoc = try? XMLDocument(xmlString: xml, options: .nodePrettyPrint) {
                if let prettyXml = try? XMLElement.init(xmlString:"\(xml)") {
                    let data = xmlDoc.xmlData(options:.nodePrettyPrint)
                    let formattedXml = String(data: data, encoding: .utf8)!
                    //                print("policy xml:\n\(formattedXml)")
                    
                    do {
                        try formattedXml.write(toFile: endpointPath+"/"+xmlFile, atomically: true, encoding: .utf8)
                    } catch {
                        if debug { vc.writeToLog(stringOfText: "Problem writing \(endpointPath) folder: Error \(error)\n") }
                        return
                    }
                }   // if let prettyXml - end
            }
        }
        
    }
}
