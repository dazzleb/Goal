//
//  GoalFlow.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/31.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
import UIKit

enum GoalStep: Step {
    case goalIsRequired
}

final class GoalFlow: Flow {
  
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
        guard let step = step as? GoalStep else { return FlowContributors.none }
        
        switch step {
        case .goalIsRequired:
            let goalVC = GoalViewController()
            self.rootViewController.pushViewController(goalVC, animated: true)
            
            return .one(flowContributor: .contribute(withNext: goalVC))
        default:
            return .none
        }
    }
}
