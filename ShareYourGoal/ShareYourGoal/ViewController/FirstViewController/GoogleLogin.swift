//
//  googleLogin.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
extension GoalViewController {
    func startGoogleLogin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
          guard error == nil else {
              print("첫번째 관문")
              return
          }

          guard let user = result?.user,
            let idToken = user.idToken?.tokenString
          else {
              print("두번째 관문")
              return
          }

          let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)

          // ...
            Auth.auth().signIn(with: credential) { result, error in
                print("로그인 실패:  \(error.debugDescription)")
              // At this point, our user is signed in\
                print("로그인 성공 유저:  \(result?.user.uid)")
            }
            // 로그아웃
//            let firebaseAuth = Auth.auth()
//            do {
//              try firebaseAuth.signOut()
//            } catch let signOutError as NSError {
//              print("Error signing out: %@", signOutError)
//            }
        }
    }
}
