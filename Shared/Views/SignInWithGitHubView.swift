//
//  SignInWithGitHubView.swift
//  Push Request
//
//  Created by Richard Robinson on 2020-11-23.
//

import Foundation
import SwiftUI

struct SignInWithGitHubView: View {
    let onPress: () -> Void
    
    var body: some View {
        VStack {
            Text("Welcome to Push Request")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 80)
            
            Spacer()
            
            CTAButton(image: Image("GitHub Logo"), label: "Sign in with GitHub", action: onPress)
                .padding(.bottom, 50)
        }
    }
}

struct SignInWithGitHubView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithGitHubView {
            
        }
    }
}
