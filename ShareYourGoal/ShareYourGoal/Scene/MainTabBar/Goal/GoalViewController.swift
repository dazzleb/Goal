//
//  GoalViewController.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/31.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import ReactorKit
import Then
import SnapKit
import GoogleSignIn
import RxFlow

class GoalViewController : UIViewController, Stepper {
    
    
    var steps: RxRelay.PublishRelay<RxFlow.Step> = PublishRelay()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .brown
    }
}
