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
// 뷰 -> 액션(1,2,3) -> 리액터 -> mutate -> reduce -> state
final class LoginReactor: Reactor {
    var initialState: State
    // 사용자로 부터 들어오는 액션
    enum Action {
        
    }
    // 사용자로 부터 들어오는 액션을 토대로
    // 상태를 바꾸는 로직처리
    enum Mutation {
        
    }
    
    struct State {
        
    }
    init(initialState: State) {
        self.initialState = initialState
    }
    func mutate(action: Action) -> Observable<Mutation> {
        switch action{
            
        }
    }
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        return newState
    }
}
