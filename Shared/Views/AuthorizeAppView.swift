//
//  SignInWithGitHubView.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-23.
//

import Foundation
import SwiftUI

struct AuthorizeAppView: View {
    let onPress: () -> Void
    
    var body: some View {
        VStack {
            Text("Almost there!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 80)
                .padding(.horizontal)
            
            Spacer()
            
            CTAButton(image: Image("GitHub Logo"), label: "Authorize Push Request", action: onPress)
                .padding(.bottom, 50)
        }
    }
}

struct AuthorizeAppView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizeAppView {
            
        }
    }
}
