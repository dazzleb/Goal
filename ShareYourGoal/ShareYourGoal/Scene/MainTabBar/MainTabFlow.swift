//
//  MainTabFlow.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/31.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
import RxRelay
import UIKit

enum MainTabStep : Step {
    
    enum TabType : Int{
        case goal       = 0
        case share      = 1
        case setting    = 2
     
    }
    // 메인탭
    case mainTabIsRequired
    
}

class MainTabFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    lazy var rootViewController : UITabBarController = UITabBarController()

    init() {
        print(#fileID, #function, #line, "- ")
    }
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? MainTabStep else { return .none }
        
        switch step {
        case .mainTabIsRequired:
            return navigateToMainTabScreen()
        }
    }
    private func navigateToMainTabScreen(_ focused: MainTabStep.TabType = .goal ) -> FlowContributors {
        

        let goalFlow = GoalFlow()
        let shareFlow = ShareFlow()
        let settingFlow = SettingFlow()
        
        Flows.use(goalFlow,shareFlow,settingFlow, when: .ready) { [unowned self] (root1: UINavigationController,
                                                                                  root2:UINavigationController,
                                                                                  root3:UINavigationController) in
            let tabBarItem1 = UITabBarItem(title: "목표", image: UIImage(systemName: "square.and.pencil.circle"), selectedImage: nil)
            root1.tabBarItem = tabBarItem1
            root1.title = "목표"
            
            let tabBarItem2 = UITabBarItem(title: "공유", image: UIImage(systemName: "shared.with.you"), selectedImage: nil)
            root2.tabBarItem = tabBarItem2
            root2.title = "공유"
            
            let tabBarItem3 = UITabBarItem(title: "설정", image: UIImage(systemName: "gear"), selectedImage: nil)
            root3.tabBarItem = tabBarItem3
            root3.title = "설정"
            
            
            self.rootViewController.setViewControllers([root1,root2,root3], animated: false)
            
//            print("check point \(self.rootViewController.tabBar.items?.count)")
            
        }

        return .multiple(flowContributors: [
                                            .contribute(withNextPresentable: goalFlow,withNextStepper: OneStepper(withSingleStep: GoalStep.goalIsRequired)),
                                            .contribute(withNextPresentable: shareFlow, withNextStepper: OneStepper(withSingleStep: ShareStep.shareIsRequired)),
                                            .contribute(withNextPresentable: settingFlow, withNextStepper: OneStepper(withSingleStep: SettingStep.settingIsRequired))
        ])
    }
}
