//
//  BarcodeScanner.swift
//  BarcodeScanner
//
//  Created by Kenneth Oliver Rathbun on 1/6/24.
//

import SwiftUI

struct BarcodeScanner: View {
    var body: some View {
        NavigationStack {
            VStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                
                Spacer().frame(height: 60)
                
                Label("Scanned Barcode: ", systemImage: "barcode.viewfinder")
                Text("not yet scanned".capitalized)
                    .bold()
                    .font(.largeTitle)
                    .foregroundStyle(.green)
                    .padding()
            }
            .navigationTitle("Barcode Scanner")
            
        }
    }
}

#Preview {
    BarcodeScanner()
}
