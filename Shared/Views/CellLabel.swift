//
//  CellLabel.swift
//  Push Request (iOS)
//
//  Created by Richard Robinson on 2020-12-06.
//

import SwiftUI

struct CellLabel: View {
    let title: String
    let textColor: Color
    let image: Image
    let iconColor: Color
    
    func labelTitle() -> some View {
        Text(title)
            .foregroundColor(textColor)
            .padding(.vertical, 10)
    }
    
    func icon() -> some View {
        RoundedRectangle(cornerRadius: 8)
            .accentColor(iconColor)
            .overlay(
                self.image
                    .font(Font.system(size: 18, weight: .semibold, design: .default))
                    .frame(width: 20, height: 20)
                    .accentColor(.white)
            )
            .frame(width: 32, height: 32)
    }
    
    var body: some View {
        Label(title: labelTitle, icon: icon)
    }
}

struct CellLabel_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            CellLabel(
                title: "Hello",
                textColor: .primary,
                image: .init(systemName: "bell.fill"),
                iconColor: .ghPurple
            )
        }
    }
}
