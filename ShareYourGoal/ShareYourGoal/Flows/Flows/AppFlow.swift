//
//  AppFlow.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/26.
//

import UIKit

import RxFlow
import RxCocoa
import RxSwift
final class AppFlow: Flow {
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController = {
        // 바 히든
        let nav = UINavigationController()
        nav.setNavigationBarHidden(false, animated: false)
        return nav
    }()
    init() {}
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        
        guard let step = step as? AppStep else { return FlowContributors.none }
        
        switch step {
            
        case .loginApiIsRequired:
            return navigationToLoginScreen()
            
        case .profileSetting(let userInfo):
            return navigationToProfileRegister(userInfo)
            
        case .mainTabBarIsRequired(let userInfo):
            return navigationToTabBar(userInfo)
            
        default:
            return .none
        }
    }// navigate
    
    private func navigationToLoginScreen() -> FlowContributors {
        let loginReactor = LoginReactor()
        let vc = LoginViewController(with: loginReactor)
        self.rootViewController.pushViewController(vc, animated: true)
        // 1. presenter : vc, flow
        // 2. stepper : 일반(OneStepper) / 커스텀 - 리모콘으로 조작가능
//        return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: loginReactor))
        return .one(flowContributor: .contribute(withNext: vc))
    }
    
    private func navigationToProfileRegister(_ userInfo: UserInfoData) -> FlowContributors {
        let vc = ProfileRegisterViewController(userInfo: userInfo)
        self.rootViewController.pushViewController(vc, animated: true)
//        self.rootViewController.setViewControllers([vc], animated: true)
        return .one(flowContributor: .contribute(withNext: vc))
    }
    
    private func navigationToTabBar(_ userInfo: UserInfoData) -> FlowContributors {
        let tab = MainTabFlow()
        let tabBar = tab.rootViewController
        self.rootViewController.setViewControllers([tabBar], animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: tab, withNextStepper: OneStepper(withSingleStep: MainTabStep.mainTabIsRequired)))
    }
}
