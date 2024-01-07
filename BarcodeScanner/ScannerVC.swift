//
//  ScannerVC.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/6/24.
//

import AVFoundation
import UIKit

protocol ScannerVCDelegate: AnyObject {
    func didFind(barcode: String)
}

final class ScannerVC: UIViewController {
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var scannerDelegate: ScannerVCDelegate
    
    init(scannerDelegate: ScannerVCDelegate) {
        self.scannerDelegate = scannerDelegate
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupCaptureSession() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            try videoInput = AVCaptureDeviceInput(device: videoCaptureDevice)
        } 
        catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } 
        else {
            return
        }
    }
    
}
