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
import RxSwift
import RxCocoa
import RxRelay


final class GoogleLoginService : NSObject {
    static let shared = GoogleLoginService()
    var disposeBag : DisposeBag = DisposeBag()
    var currentNonce: String?
    let userInfoBehavior : BehaviorRelay<UserInfoData> = BehaviorRelay(value: UserInfoData(id: "", nickName: "", profileURL: ""))
    override init() {
        super.init()
    }
   
    func startGoogleLogin() -> Observable<UserInfoData> {
        // 일단 viewController 필요로함 저게 맞나?
        // 반환 값으로 유저의 정보 데이터 를 반화 해주자
//        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        if let clientID =  FirebaseApp.app()?.options.clientID,
           let topVC = UIApplication.shared.topViewController() {
            // Create Google Sign In configuration object.
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
//            let loginVC = LoginViewController()
            // Start the sign in flow!
            
            GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [unowned self] result, error in
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
                let googleClientId = FirebaseApp.app()?.options.clientID ?? ""
                let signInConfig = GIDConfiguration.init(clientID: googleClientId)
                print("signInConfig:\(signInConfig)")
                
                
//                let fullName = user.profile?.name
////                let giveName = user.profile?.givenName
////                let emailAddress = user.profile?.email
//                let profileURL = user.profile?.imageURL(withDimension: 320)
//                let userID = user.userID!
//                print("fullName:\(fullName!)")
//                print("giveName:\(giveName!)")
//                print("emailAddress:\(emailAddress!)")
//                print("profileURL:\(profileURL!)")
//                print("userID:\(userID)")
    //        fullName:sihyeok park
    //        giveName:sihyeok
    //        emailAddress:dazzledazzleb@gmail.com
    //        progileURL:https://lh3.googleusercontent.com/a/AAcHTtcuDyxbI5NuQMLjid9NrQt8cW5fyiXA3UZNf41B46DMoA=s320
    //        userID:100270280170235869511
              let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                             accessToken: user.accessToken.tokenString)

              // ...
                Auth.auth().signIn(with: credential) { result, error in
                    let userID = result?.user.uid ?? ""
                    let nickName = result?.user.displayName ?? ""
                    let urlString = result?.user.photoURL?.absoluteString ?? ""
    //               guard let url = URL(string: "https://lh3.googleusercontent.com/a/AAcHTtcuDyxbI5NuQMLjid9NrQt8cW5fyiXA3UZNf41B46DMoA=s320") else {return}
//                    let urlString = profileURL?.absoluteString
                  
                    
                    let userInfo : UserInfoData = UserInfoData(id: userID,
                                                               nickName: nickName ?? "" ,
                                                               profileURL: urlString ?? ""
                                                              )
                    
                    userInfoBehavior.accept(userInfo)
                    print("로그인 실패:  \(error.debugDescription)")
                  // At this point, our user is signed in
                    print("로그인 성공 유저:  \(result?.user.uid)")
                    //Optional("T9qMt6nn77d65MzI6Pc5DUJ21dM2")
    //                let MainViewController = ProfileRegisterViewController()
    //                self.navigationController?.viewControllers = [MainViewController]
                    
                }
        }
            
        }//GIDSignIn
        let userInfoObservable: Observable<UserInfoData> = userInfoBehavior.asObservable()
        return userInfoObservable
    }//fkask
}
extension LoginViewController {
    
}
// 로그아웃
//            let firebaseAuth = Auth.auth()
//            do {
//              try firebaseAuth.signOut()
//            } catch let signOutError as NSError {
//              print("Error signing out: %@", signOutError)
//            }
//private func showMainViewController(fullName: String , giveName: String, emailAddress: String, profileURL: URL, userID: String) {
//
//    let nextVC = ChannelViewController(userNickname: currentUserName, userIdentifier: userIdentifier)
//    self.navigationController?.viewControllers = [nextVC]
//}
