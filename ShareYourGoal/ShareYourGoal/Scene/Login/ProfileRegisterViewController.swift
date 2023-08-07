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
import Kingfisher
import RxGesture

class ProfileRegisterViewController : UIViewController, StoryboardView, Stepper{
    typealias Reactor = LoginReactor
    var disposeBag: DisposeBag = DisposeBag()
    
    var steps: PublishRelay<Step> = PublishRelay()
    
    var nickName: String = ""
    
    var ref: DocumentReference? = nil
    let db = Firestore.firestore()
    
    var profileImgSelectedRelay : PublishRelay<UIImage> = PublishRelay()
    
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
        NameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .subscribe(onNext: { text in
                self.nickName = text
            }).disposed(by: disposeBag)
        
        // 이미지 뷰의 탭 제스처를 RxSwift Observable로 변환
                storedProfileImg.rx.tapGesture()
                    .when(.recognized)
                    .subscribe(onNext: { _ in
                        print("tapped!")
                        self.openLibrary()
                    })
                    .disposed(by: disposeBag)
       
    }
    
    
    //MARK: - BIND
    func bind(reactor: LoginReactor) {
        profileImgSelectedRelay
            .compactMap {
                $0.jpegData(compressionQuality: 0.5)
            }
            .debug("이미지 🎨")
            .map { Reactor.Action.uploadProfileImg(imgData: $0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // 네비게이션 바 확인 버튼
        rightItem.rx.tap
            .debug("⭐️ 확인")
            .map { Reactor.Action.profileSetting(nickName: self.nickName)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        // state 에 닉네임이 있다면 텍스트필드 텍스트에 값 넣기
        reactor
            .state
            .map{ $0.userInfo.nickName }
            .observe(on: MainScheduler.instance)
            .bind(onNext: { existingNickname in
                self.NameTextField.text = existingNickname
            })
            .disposed(by: disposeBag)
        
        reactor
            .state
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
                self.storedProfileImg
                    .kf
                    .setImage(with: URL(string: info.userInfo.profileURL)!)
//                self.steps.accept(AppStep.mainTabBarIsRequired(userInfoData: uesrInfo))
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - UI
    func configureUI(){
        self.navigationItem.title = "프로필 설정"
        self.navigationItem.rightBarButtonItem = rightItem
        
        profileStackView.addArrangedSubview(storedProfileImg)
        profileStackView.addArrangedSubview(NameTextField)
        profileStackView.addArrangedSubview(bottomBar)
        self.view.addSubview(profileStackView)
        
        //기본 이미지
//        if let defaultImgURL = URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541"){
//            storedProfileImg.kf.setImage(with: defaultImgURL)
//        }
        
        // 스택뷰
        profileStackView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.centerX.equalToSuperview()
            //            $0.height.equalTo(450)
        }
        // 이미지
        storedProfileImg.snp.makeConstraints {
            $0.size.equalTo(180)
        }
        // 이름 텍스트 필드
        NameTextField.snp.makeConstraints {
            $0.height.equalTo(28)
            $0.top.equalTo(self.storedProfileImg.snp.bottom).offset(40)
            $0.left.equalTo(self.profileStackView.snp.left)
            $0.width.equalTo(300)
        }
        bottomBar.snp.makeConstraints {
            $0.top.equalTo(self.NameTextField.snp.bottom).offset(10)
            $0.left.equalTo(self.profileStackView.snp.left)
            $0.height.equalTo(1)
            $0.width.equalTo(300)
        }
    }
    
    /// 네비게이션 아이템
    lazy var rightItem: UIBarButtonItem = UIBarButtonItem().then {
        $0.title = "확인"
    }
    /// 프로필 스택
    lazy var profileStackView : UIStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        //        $0.backgroundColor = .white
        $0.spacing = 20
    }
   
    /// 이미지 저장소
    lazy var storedProfileImg : UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 90
        $0.clipsToBounds = true
    }
    
    /// 닉네임 텍스트필드
    lazy var NameTextField : UITextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요."
        $0.font = .systemFont(ofSize: 28, weight: .heavy)
        $0.textColor = UIColor(named: "MainFontColor")
        
        
    }
    /// 밑줄
    lazy var bottomBar :UIView = UIView().then {
        $0.backgroundColor = .black
    }
}

//MARK: Photo
extension ProfileRegisterViewController {
    /// 사진
        private func openLibrary(){
        print(#fileID, #function, #line, "- ")
        
        /// Load Photos
         PHPhotoLibrary.requestAuthorization { (status) in
             switch status {
             case .authorized:
                 print("Good to proceed")
                 DispatchQueue.main.async {
                     self.presentPicker(filter: .images)
                 }
//                 let fetchOptions = PHFetchOptions()
//                 self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
             case .denied, .restricted:
                 print("Not allowed")
             case .notDetermined:
                 print("Not determined yet")
             case .limited:
                 print("limited")
             @unknown default:
                 print("default")
             }
         }
        
        
    }
}

extension ProfileRegisterViewController {
    
    /// - Tag: PresentPicker
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
        
        var newSelection = [String: PHPickerResult]()
        
        for result in results {
            let identifier = result.assetIdentifier!
            newSelection[identifier] = result
        }
        
        guard let selectedImgId = results.compactMap{ $0.assetIdentifier }.first else {
            print(#fileID, #function, #line, "- 이미지 에셋이 없다")
            return
        }
        
        guard let currentItemProvider = newSelection[selectedImgId]?.itemProvider else {
            return
        }
        
        guard currentItemProvider.canLoadObject(ofClass: UIImage.self) == true else {
            return
        }
        
        currentItemProvider.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] image, error in
            if let profileImg = image as? UIImage {
//                self?.profileImgSelected?(profileImg)
                self?.profileImgSelectedRelay.accept(profileImg)
                DispatchQueue.main.async {
                    self?.dismiss(animated: true)
                }
            }
        })

    }
}
