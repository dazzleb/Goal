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
import FirebaseFirestore
import PhotosUI
class ProfileRegisterViewController : UIViewController, StoryboardView, Stepper{
    typealias Reactor = LoginReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    var steps: PublishRelay<Step> = PublishRelay()
    
//    var profile: String = ""
    var nickName: String = ""
    
    var ref: DocumentReference? = nil
    let db = Firestore.firestore()
    
    init(userInfo: UserInfoData){
        super.init(nibName: nil, bundle: nil)
        self.reactor = LoginReactor(initialState: LoginReactor.State(userInfo: userInfo))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "BackColor")
        configureUI()
        
        // 닉네임변경 시 변수에 텍스트 값 넣기
        nickNameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { text in
                self.nickName = text
            }).disposed(by: disposeBag)
    }
    
    
    //MARK: - BIND
    func bind(reactor: LoginReactor) {
        // 네비게이션 바 저장 버튼
        rightItem.rx.tap
            .debug("⭐️ 저장")
            .map { Reactor.Action.profileSetting(nickName: self.nickName)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // state 에 닉네임이 있다면 텍스트필드 텍스트에 값 넣기
        reactor
            .state
            .map{ $0.userInfo.nickName }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { existingNickname in
                self.nickNameTextField.text = existingNickname
            })
            .disposed(by: disposeBag)
        
        reactor
            .state
            .filter{ info in
                info.userInfo.username != nil
            }
            .bind(onNext: { info in
                let uesrInfo = info.userInfo
                self.db.collection("goal")
                    .document(info.userInfo.id)
                    .setData([
                        "id": info.userInfo.id,
                        "nickName": info.userInfo.username ?? "",
                        "profileURL": info.userInfo.profileURL
                    ]) { err in
                        
                    }

                self.steps.accept(AppStep.mainTabBarIsRequired(userInfoData: uesrInfo))
            })
            .disposed(by: disposeBag)
        
        
    }
    //    if let imageURL = URL(string: data.profileImage){
    //        userProfile.kf.setImage(with: imageURL)
    //    }
    //MARK: - UI
    func configureUI(){
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = rightItem
        
        profileStackView.addArrangedSubview(storedProfileImg)
        profileStackView.addArrangedSubview(nickNameTextField)
        //        profileStackView.addArrangedSubview(bottomBar)
        self.view.addSubview(profileStackView)
        
        profileStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
//            $0.height.equalTo(450)
        }
        storedProfileImg.snp.makeConstraints {
            $0.size.equalTo(90)
        }
        nickNameTextField.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.top.equalTo(self.storedProfileImg.snp.bottom).offset(10)
            $0.left.equalTo(self.profileStackView.snp.left)
            $0.width.equalTo(300)
        }
    }
    
    /// 네비게이션 아이템
    lazy var rightItem: UIBarButtonItem = UIBarButtonItem().then {
        $0.title = "저장"
    }
    /// 프로필 스택
    lazy var profileStackView : UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.backgroundColor = .white
        $0.spacing = 20
    }
    /// 이미지 저장소
    lazy var storedProfileImg : UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 45
        $0.backgroundColor = .red
        $0.clipsToBounds = true
        
        
    }
    /// 닉네임 텍스트필드
    lazy var nickNameTextField : UITextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요."
        $0.font = .systemFont(ofSize: 28, weight: .heavy)
        $0.textColor = UIColor(named: "MainFontColor")
    }
    /// 밑줄
    lazy var bottomBar :UIView = UIView().then {
        $0.backgroundColor = .brown
    }
}

extension ProfileRegisterViewController  {
    private func presentPicker(filter: PHPickerFilter?) {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        // Set the filter type according to the user’s selection.
        configuration.filter = filter
        // Set the mode to avoid transcoding, if possible, if your app supports arbitrary image/video encodings.
        configuration.preferredAssetRepresentationMode = .current
        // Set the selection behavior to respect the user’s selection order.
//        configuration.selection = .ordered
        // Set the selection limit to enable multiselection.
//        configuration.selectionLimit = 0
        // Set the preselected asset identifiers with the identifiers that the app tracks.
//        configuration.preselectedAssetIdentifiers = selectedAssetIdentifiers
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}
extension ProfileRegisterViewController: PHPickerViewControllerDelegate {
    /// - Tag: ParsePickerResults
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
//        let existingSelection = self.selection
        var newSelection = [String: PHPickerResult]()
        for result in results {
            let identifier = result.assetIdentifier!
//            newSelection[identifier] = existingSelection[identifier] ?? result
        }
        
        // Track the selection in case the user deselects it later.
//        selection = newSelection
//        selectedAssetIdentifiers = results.map(\.assetIdentifier!)
//        selectedAssetIdentifierIterator = selectedAssetIdentifiers.makeIterator()
//
//        if selection.isEmpty {
//            displayEmptyImage()
//        } else {
//            displayNext()
//        }
    }
}
