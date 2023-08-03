//
//  AppStepper.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/27.
//

import RxFlow
import RxCocoa
import RxRelay
import RxSwift
class AppSteper: Stepper {
    var steps: RxRelay.PublishRelay<RxFlow.Step> = PublishRelay()
    
    var initialStep: Step {
        return AppStep.loginApiIsRequired
    }
    // 뭐에 쓰는건지 모르겠음 그냥 스탭이 방출될 때 마다 알려주는건가 봄
    func readyToEmitSteps() {
        print(#fileID, #function, #line, "- ")
    }
    
}
