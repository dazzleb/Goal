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
    
    var initialState: State
    // 사용자로 부터 들어오는 액션
    enum Action {
        case google
        case profileSetting(nickName: String,profileURL: String)
    }
    // 사용자로 부터 들어오는 액션을 토대로
    // 상태를 바꾸는 로직처리
    enum Mutation {
        case googleLoginUserInfo(userInfo: UserInfoData)
        case profile(updateUserInfo: UserInfoData)
    }
    
    struct State {
        var userInfo : UserInfoData
    }

    init(initialState: State = State(userInfo: UserInfoData(id: "", email: "", nickName: "", profileURL: ""))) {
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
        case .profileSetting(let nickName,let profileURL):
         
            let updateUserInfo : UserInfoData = UserInfoData(id: currentState.userInfo.id, email: currentState.userInfo.email, nickName: nickName, profileURL: profileURL)

            return  Observable.just(()).map{ Mutation.profile(updateUserInfo: updateUserInfo) }
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .googleLoginUserInfo(userInfo: let user):
            newState.userInfo = user
        case .profile(updateUserInfo: let updateUserInfo):
            newState.userInfo = updateUserInfo
        }
        return newState
    }
}
