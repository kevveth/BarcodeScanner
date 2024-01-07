//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/6/24.
//

import AVFoundation
import UIKit

// Protocol for communicating barcode scanning results back to other classes
protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String) // Called when a barcode is successfully scanned
}

// View controller responsible for managing barcode scanning
final class ScannerVC: UIViewController {
    let captureSession = AVCaptureSession()  // Session for capturing video
    var previewLayer: AVCaptureVideoPreviewLayer?  // Layer for displaying camera preview
    weak var scannerDelegate: ScannerVCDelegate?  // Delegate to receive barcode results
    
    // Initialize with a delegate to handle scanned barcodes
    init(scannerDelegate: ScannerVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.scannerDelegate = scannerDelegate
    }
    
    // Required initializer for storyboards (not implemented here)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // Set up the capture session and preview layer
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        // Create a video input from the device
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Add the video input to the capture session if possible
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        // Create a metadata output for barcode detection
        let metaDataOutput = AVCaptureMetadataOutput()
        
        // Add the metadata output to the capture session if possible
        if captureSession.canAddOutput(metaDataOutput) {
            captureSession.addOutput(metaDataOutput)
            metaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main) // Set delegate for barcode detection
            metaDataOutput.metadataObjectTypes = [.ean8, .ean13] // Specify supported barcode types
        } else {
            return
        }
        
        // Create a video preview layer and add it to the view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer!.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)
        
        // Run the capture session
        captureSession.startRunning()
    }
    
}

// Extension to handle barcode detection events
extension ScannerVC: AVCaptureMetadataOutputObjectsDelegate {
    // Called when a barcode is detected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let object = metadataObjects.first else {
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else {
            return
        }
        
        // Notify the delegate about the scanned barcode
        scannerDelegate?.didFind(barcode: barcode)
    }
}
