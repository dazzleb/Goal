//
//  GoalViewReactor.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//

import Foundation
import ReactorKit
import RxSwift
import RxRelay
import RxFlow


// 뷰 -> 액션(1,2,3) -> 리액터 -> mutate -> reduce -> state
final class LoginReactor: Reactor {
//    let value2: MyEnum = .customObjectWithInfo(name: "John", age: 30)

//    struct Profileupdate {
//        let nickName: String
//        let profileURL: String
//    }
    //    if let imageURL = URL(string: data.profileImage){
    //        userProfile.kf.setImage(with: imageURL)
    //    }

    let appleLoginService = AppleLoginService.shared
    var initialState: State
    // 사용자로 부터 들어오는 액션
    enum Action {
        case google
        case Apple
        case profileSetting(nickName: String)
        case uploadProfileImg(imgData: Data)
    }
    // 사용자로 부터 들어오는 액션을 토대로
    // 상태를 바꾸는 로직처리
    enum Mutation {
        case googleLoginUserInfo(userInfo: UserInfoData)
        case appleLoginUserInfo(userInfo: UserInfoData)
        case profile(updateUserInfo: UserInfoData)
        case uploadProfileImg(imgUrl: String)
    }
    
    struct State {
        var userInfo : UserInfoData
    }

    init(initialState: State = State(userInfo: UserInfoData(id: "", nickName: "", profileURL: ""))) {
        self.initialState = initialState
    }
    
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
        case .google:  // 반환 받아오는 유저 데이터 를 state 에 저장  작업
            return Observable.concat([
                GoogleLoginService.shared.startGoogleLogin()
                    .map({ userInfoData in
//                        self.steps.accept(AppStep.profileSetting)
                         Mutation.googleLoginUserInfo(userInfo: userInfoData)
                    })
            ])
        case .Apple://유저 데이터 state 에 저장
            // apple service 에서 반환 받아오는 userData 보내주기
            return Observable.concat([
                self.appleLoginService.startSignInWithAppleFlow()
                    .map({ userInfoData in
                        let userInfo =  UserInfoData(id: userInfoData.id, nickName:  userInfoData.nickName, profileURL: userInfoData.profileURL)
                        return Mutation.appleLoginUserInfo(userInfo: userInfo)
                    })
            ])
        case .profileSetting(let nickName):  //프로필 수정 업데이트
         // 맞나?
            let url = currentState.userInfo.profileURL
            let updateUserInfo : UserInfoData = UserInfoData(id: currentState.userInfo.id, nickName: nickName, profileURL: url, username: nickName)

            return  Observable.just(()).map{ Mutation.profile(updateUserInfo: updateUserInfo) }
        
        case .uploadProfileImg(imgData: let imgData):
            // 인자 로 uid 필요
            let userUid = currentState.userInfo.id
            
            // 파이어베이스 스토어 서비스 작업 ㄱ
            return Observable.concat([
                FirebaseStorageService
                    .shared
                    .uploadProfileImg(userUid: userUid, data: imgData)
                    .debug(" 업로드 프로필 이미지 주소")
                    .map({ profileURL in
                        Mutation.uploadProfileImg(imgUrl: profileURL)
                    })
            ])
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .googleLoginUserInfo(userInfo: let user):
            newState.userInfo = user
        case .appleLoginUserInfo(userInfo: let user):
            newState.userInfo = user
        case .profile(updateUserInfo: let updateUserInfo):
            newState.userInfo = updateUserInfo
        case .uploadProfileImg(imgUrl: let imgUrl):
            let updatedUserInfo = UserInfoData(id: currentState.userInfo.id,
                                               nickName: currentState.userInfo.nickName
                                               ,profileURL: imgUrl)
            newState.userInfo = updatedUserInfo
            
        }
        return newState
    }
}
