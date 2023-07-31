//
//  MainViewController.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxRelay
import ReactorKit
import Then
import SnapKit
import RxFlow
class ProfileRegisterViewController : UIViewController, StoryboardView, Stepper{
    typealias Reactor = LoginReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    var steps: PublishRelay<Step> = PublishRelay()
    
    let profile: String = ""
    let nickName: String = ""
    
    init(userInfo: UserInfoData){
        super.init(nibName: nil, bundle: nil)
        self.reactor = LoginReactor(initialState: LoginReactor.State(userInfo: userInfo))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "BackColor")
        configureUI()
        
        
        
    }
    lazy var rightItem: UIBarButtonItem = UIBarButtonItem().then {
        $0.title = "저장"
    }

    //MARK: - BIND
    func bind(reactor: LoginReactor) {
        rightItem.rx.tap
            .debug("⭐️ 저장")
            .map { Reactor.Action.profileSetting(nickName: self.nickName, profileURL: self.profile)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor
            .state
            .bind(onNext: { info in
                let uesrInfo = info.userInfo
                self.steps.accept(AppStep.mainTabBarIsRequired(userInfoData: uesrInfo))
            })
            .disposed(by: disposeBag)
   
    }

    //MARK: - UI
    func configureUI(){
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = rightItem
    }
}
