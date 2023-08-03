//
//  ShareFlow.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/31.
//

import Foundation
import RxFlow
import RxCocoa
import RxSwift
import UIKit

enum ShareStep: Step {
    case shareIsRequired
}
final class ShareFlow: Flow {
  
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
        guard let step = step as? ShareStep else { return FlowContributors.none }
        
        switch step {
        case .shareIsRequired:
            let shareVC = ShareViewController()
            self.rootViewController.pushViewController(shareVC, animated: true)
            
            return .one(flowContributor: .contribute(withNext: shareVC))
        default:
            return .none
        }
    }
//    private func coordinateToLogin() -> FlowContributor {
////        let reactor = LoginReactor
//    }
}
