//
//  AppStep.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/26.
//

import RxFlow
import RxCocoa
import RxRelay
import RxSwift

enum AppStep: Step {
    // Login
    case loginApiIsRequired
    case profileSetting(userInfoData: UserInfoData)
    
    // MainTabBar
    case mainTabBarIsRequired(userInfoData: UserInfoData)
}

