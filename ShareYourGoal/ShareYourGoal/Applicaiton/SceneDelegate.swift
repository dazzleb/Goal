//
//  SceneDelegate.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//

import UIKit
import FirebaseCore
import RxFlow
import RxSwift
import RxCocoa
import RxRelay

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let disposeBag = DisposeBag()
    var coordinator = FlowCoordinator()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowSecene = (scene as? UIWindowScene) else { return }
        
        let appFlow = AppFlow() // 흐름
        let appStepper = AppSteper() // 흐름 트리거
        
        // 흐름 & 흐름 트리거 연결되었음
        self.coordinator.coordinate(flow: appFlow, with: appStepper)
        
        Flows.use(appFlow, when: .created, block: { rootVC in
            let window = UIWindow(windowScene: windowSecene)
            window.rootViewController = rootVC
            self.window = window
            window.makeKeyAndVisible()
        })
    }
   
}
