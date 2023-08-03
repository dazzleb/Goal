//
//  SettingFlow.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/31.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
import UIKit

enum SettingStep: Step {
    case settingIsRequired
}
final class SettingFlow: Flow {
  
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController = .init()
    
    init() {
     
    }
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? SettingStep else { return FlowContributors.none }
        
        switch step {
        case .settingIsRequired:
            let settingVC = SettingViewController()
            self.rootViewController.pushViewController(settingVC, animated: true)
            
            return .one(flowContributor: .contribute(withNext: settingVC))
        default:
            return .none
        }
    }
//    private func coordinateToLogin() -> FlowContributor {
////        let reactor = LoginReactor
//    }
}
