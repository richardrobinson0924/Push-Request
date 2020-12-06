//
//  CTAButton.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-26.
//

import SwiftUI

struct CTAButton: View {
    let image: Image
    let label: String
    let action: () -> Void
    
    private var overlay: some View {
        HStack(spacing: 10) {
            self.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 26, height: 26)
            
            Text(label)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(Color(.systemBackground))
        }
    }
    
    var body: some View {
        Rectangle()
            .cornerRadius(16)
            .frame(height: 52)
            .padding(.horizontal, 36)
            .overlay(overlay)
            .onTapGesture(perform: action)
    }
}

struct CTAButton_Previews: PreviewProvider {
    static var previews: some View {
        CTAButton(image: Image("GitHub Logo"), label: "Sign in with GitHub", action: {})
            .padding(.bottom, 50)
    }
}
