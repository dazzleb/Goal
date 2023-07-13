//
//  ViewController.swift
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
class GoalViewController: UIViewController, StoryboardView {
    typealias Reactor = LoginReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func bind(reactor: LoginReactor) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        configureUI()
        googleLoginBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.startGoogleLogin()
            })
            .disposed(by: disposeBag)
    }
    
    lazy var googleLoginBtn : UIButton = UIButton().then {
        $0.setTitle("Google", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1.0
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureUI(){
        self.view.addSubview(googleLoginBtn)
        googleLoginBtn.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(50)
        }
    }

}

