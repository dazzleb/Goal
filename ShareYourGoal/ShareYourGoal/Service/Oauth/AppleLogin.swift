//
//  AppleLogin.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//
import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import FirebaseCore
import FirebaseAuth
import CryptoKit
import AuthenticationServices

final class AppleLoginService : NSObject,
                                ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate{
    
    
    static let shared = AppleLoginService()
    
    var disposeBag : DisposeBag = DisposeBag()
    let userInfoBehavior : BehaviorRelay<UserInfoData> = BehaviorRelay(value: UserInfoData(id: "", nickName: "", profileURL: ""))
    var currentNonce: String?
    
    override init() {
        super.init()
    }
    // ASAuthorizationControllerPresentationContextProviding 프로토콜
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // ⭐️
        return UIApplication.shared.windows.first!
    }
    
    /// 애플로그인 플로우
    func startSignInWithAppleFlow() -> Observable<UserInfoData> {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        print(#fileID, #function, #line, "- 애플 로그인 시작")
        let userInfoObservable: Observable<UserInfoData> = userInfoBehavior.asObservable()
        
        print(#fileID, #function, #line, "- 애플 Data \(userInfoObservable.values) ")
        
        return userInfoObservable
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    // ASAuthorizationControllerDelegate 프로토콜
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            print(#fileID, #function, #line, "- \(credential)")
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription)
                    print(#fileID, #function, #line, "- 애플 로그인 실패")
                    return
                }
                print(#fileID, #function, #line, "\(authResult?.user.displayName)")
                // User is signed in to Firebase with Apple.
                // ...
                let displayName = authResult?.user.displayName ?? ""
                //                            print("displayName: \(displayName)")
                //                          guard let email = authResult?.user.email else  { return }
                let urlString = authResult?.user.photoURL?.absoluteString ?? ""
                //                          guard let providerID = authResult?.additionalUserInfo?.providerID else  { return }
                //                          guard let isNewUser = authResult?.additionalUserInfo?.isNewUser else  { return }
                let uid = authResult?.user.uid ?? ""
                let userInfo : UserInfoData = UserInfoData(id: uid, nickName: displayName, profileURL: urlString)
                print(#fileID, #function, #line, "\(userInfo)")
                self.userInfoBehavior.accept(userInfo)
                
                
                //          print("email: \(email)")
                //          print("photoURL: \(photoURL)")
                //                          print("providerID: \(providerID)")
                //          print("isNewUser: \(isNewUser)")
                //                          print("uid: \(uid)")
                
                //          let MainViewController = ProfileRegisterViewController(userInfo: <#UserInfoData#>)
                //          self.navigationController?.viewControllers = [MainViewController]
            }
        }// if let
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // Handle error.
            print("Sign in with Apple errored: \(error)")
        }
    }
}
