//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/6/24.
//

import AVFoundation
import UIKit

enum CameraError: String {
    case invalidDeviceInput
    case invalidScannedValue 
}

// Protocol for communicating barcode scanning results back to other classes
protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String) // Called when a barcode is successfully scanned
    func didSurface(error: CameraError)
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
    
    override func viewDidLoad() {
        // Call the superclass implementation for standard setup
        super.viewDidLoad()
        
        // Initialize the camera and preview for barcode scanning
        setupCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        // Call the superclass implementation for layout adjustments
        super.viewDidLayoutSubviews()
        
        // Ensure the preview layer exists before modifying its frame
        guard let previewLayer = previewLayer else {
            // Notify delegate about camera setup failure
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // Adjust the preview layer's frame to match the view's bounds,
        // ensuring proper display of the camera preview
        previewLayer.frame = view.layer.bounds
    }
    
    // Set up the capture session and preview layer
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // Create a video input from the device
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
            return
        }
        
        // Add the video input to the capture session if possible
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
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
            scannerDelegate?.didSurface(error: .invalidDeviceInput)
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
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let machineReadableObject = object as? AVMetadataMachineReadableCodeObject else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        guard let barcode = machineReadableObject.stringValue else {
            scannerDelegate?.didSurface(error: .invalidScannedValue)
            return
        }
        
        // Notify the delegate about the scanned barcode
        scannerDelegate?.didFind(barcode: barcode)
    }
}
