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
import GoogleSignIn
import RxFlow
import AuthenticationServices

class LoginViewController: UIViewController, StoryboardView, Stepper {
    
    var steps: PublishRelay<Step> = PublishRelay()
    
    typealias Reactor = LoginReactor
    
    
    var disposeBag: DisposeBag = DisposeBag()
    
    init(with reactor: LoginReactor) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    //MARK: BIND
    func bind(reactor: LoginReactor) {
        //        googleLogin(reactor)
        googleLoginMark.rx.tap
            .debug()
            .map { Reactor.Action.google }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        AppleLoginMark.rx.tap
            .debug()
            .map { Reactor.Action.Apple}
            .bind(to: reactor.action )
            .disposed(by: disposeBag)
        
        reactor
            .state
            .debug("⭐️⭐️⭐️")
            .filter{ $0.userInfo.id.count > 0 }
            .bind(onNext: {user in
                let userInfo = user.userInfo
                print("\(userInfo)")
                
                self.steps.accept(AppStep.profileSetting(userInfoData: userInfo))
            }).disposed(by: disposeBag)
            
           
    }
    
    private func googleLogin(_ reactor: LoginReactor){
        googleLoginMark.rx.tap
            .map { Reactor.Action.google }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
        
    }
    //MARK: - UI
    func configureUI(){
        self.view.backgroundColor = UIColor(named: "BackColor")
        self.view.addSubview(subTitle)
        self.view.addSubview(mainTitle)
        self.view.addSubview(loginStackView)
        
        self.loginStackView.addArrangedSubview(googleLoginMark)
        self.loginStackView.addArrangedSubview(AppleLoginMark)
        subTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview()
        }
        mainTitle.snp.makeConstraints { make in
            make.top.equalTo(subTitle.snp.bottom).offset(5)
            make.left.right.equalToSuperview()
        }
        loginStackView.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(100)
            make.left.equalTo(self.view.snp.left).offset(85)
            make.centerX.equalToSuperview()
        }
        googleLoginMark.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        AppleLoginMark.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }
    
    lazy var subTitle: UILabel = UILabel().then {
        $0.text = "목표 공유 커뮤니티"
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 28, weight: .medium)
        $0.textColor = UIColor(named: "MainFontColor")
    }
    
    lazy var mainTitle: UILabel = UILabel().then {
        $0.text = "목          공"
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 58, weight: .heavy)
        $0.textColor = UIColor(named: "MainFontColor")
        
        //Font 그림자 효과 설정
        $0.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        $0.layer.shadowOffset = CGSize(width: 9, height: -4)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.5
    }
    
    lazy var loginStackView : UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 15
        $0.distribution = .fillEqually
    }
    
    lazy var googleLoginMark: UIButton = UIButton(type: .custom).then {
        
        //        let focusImage = UIImage(named: "FoucsGoogle_Image")
        //        $0.setImage(focusImage, for: .highlighted)
        //        let nomalImage = UIImage(named: "NomalGoogle_Image")
        //        $0.setImage(nomalImage, for: .normal)
        guard let image = UIImage(named: "GoogleLogo") else {
            // 이미지 로드에 실패한 경우에 대한 처리
            return
        }
        $0.setImage(image, for: .normal)
        $0.setTitle("Sign in with Google", for: .normal)
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.setTitleColor(UIColor(named: "GoogleFontColor"), for: .normal)
        
        $0.adjustsImageWhenHighlighted = false // 이미지 반전 제거
        $0.backgroundColor = UIColor(named: "GoogleLoginBGColor")
        
        $0.clipsToBounds = false
        $0.layer.cornerRadius = 14
        $0.layer.borderColor = UIColor(named: "BoderColor")?.cgColor
        
        $0.imageView?.contentMode = .scaleAspectFit
        $0.layer.borderColor = UIColor(named: "BoderColor")?.cgColor
        $0.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.5
    }
    
    lazy var AppleLoginMark: UIButton = UIButton(type: .custom).then {
        guard let image = UIImage(named: "AppleLogo") else {
            // 이미지 로드에 실패한 경우에 대한 처리
            return
        }
        $0.setImage(image, for: .normal)
        $0.setTitle("Sign in with Apple", for: .normal)
        $0.adjustsImageWhenHighlighted = false // 이미지 반전 제거
        $0.imageView?.contentMode = .scaleAspectFit
        
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.setTitleColor(UIColor(named: "AppleFontColor"), for: .normal)
        
        $0.backgroundColor = UIColor(named: "AppleBGColor")
        
        $0.clipsToBounds = false
        $0.layer.cornerRadius = 14
        $0.layer.borderColor = UIColor(named: "BoderColor")?.cgColor
        $0.layer.shadowColor = UIColor(named: "ShadowColor")?.cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowRadius = 4
        $0.layer.shadowOpacity = 0.5
    }
}


