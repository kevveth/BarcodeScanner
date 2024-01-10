//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/9/24.
//

import SwiftUI

// MARK: - UIViewControllerRepresentable for barcode scanning
struct ScannerView: UIViewControllerRepresentable {
    // Bind scanned code and alert state to SwiftUI view
    @Binding var scannedCode: String
    @Binding var alertItem: AlertItem?
    
    // MARK: - UIViewControllerRepresentable methods
    
    // Create the ScannerVC, passing coordinator as delegate
    func makeUIViewController(context: Context) -> ScannerVC {
        ScannerVC(scannerDelegate: context.coordinator)
    }
    
    // Update the view controller (not needed in this case)
    func updateUIViewController(_ uiViewController: ScannerVC, context: Context) {}
    
    // Create a coordinator to handle delegate callbacks
    func makeCoordinator() -> Coordinator {
        Coordinator(scannerView: self)
    }
    
    // MARK: - Coordinator to bridge SwiftUI and UIKit
    final class Coordinator: NSObject, ScannerVCDelegate {
        private let scannerView: ScannerView
        
        init(scannerView: ScannerView) {
            self.scannerView = scannerView
        }
        
        // Handle scanned barcodes
        func didFind(barcode: String) {
            scannerView.scannedCode = barcode
        }
        
        // Handle camera errors
        func didSurface(error: CameraError) {
            switch error {
            case .invalidDeviceInput:
                scannerView.alertItem = AlertContext.invalidDeviceInput
            case . invalidScannedValue:
                scannerView.alertItem = AlertContext.invalidScannedType
            }
        }
    }
}
