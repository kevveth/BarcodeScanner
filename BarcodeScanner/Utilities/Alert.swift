//
//  Alert.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/10/24.
//

import Foundation
import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    
    let title: String
    let message: String
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let invalidDeviceInput = AlertItem(title: "Invalid Device Input",
                                              message: "Something is wrong with the camera. Unable to capture the input.",
                                              dismissButton: .default(Text("Ok")))
    static let invalidScannedType = AlertItem(title: "Invalid Scan Type",
                                              message: "The value scanned is not valid. This app scans EAN-8 and EAN-13.",
                                              dismissButton: .default(Text("Ok")))
}
