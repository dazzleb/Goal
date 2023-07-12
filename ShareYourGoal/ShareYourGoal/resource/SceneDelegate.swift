//
//  SceneDelegate.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/07/13.
//

import UIKit
import FirebaseCore
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        FirebaseApp.configure()
        // 1. scene 캡처
        guard let windowSecene = (scene as? UIWindowScene) else { return }
        
        // 2. window scene을 가져오는 windowScene을  생성자를 사용해서 UIWindow를 생성
        let window = UIWindow(windowScene: windowSecene)
        
        // 3. view 계층을 프로그래밍 방식으로 만들기
        let firstViewController = UINavigationController(rootViewController: GoalViewController())
        let secondViewController = UINavigationController(rootViewController: CommunityViewController())
        let thirdViewController = UINavigationController(rootViewController: SettingViewController())
        let tabBarController = UITabBarController()
            tabBarController.setViewControllers([firstViewController, secondViewController, thirdViewController], animated: true)
        if let tabBarItems = tabBarController.tabBar.items {
                tabBarItems[0].selectedImage = UIImage(systemName: "square.and.pencil.circle.fill")
                tabBarItems[0].image = UIImage(systemName: "square.and.pencil.circle")
                tabBarItems[0].title = "Goals"

                tabBarItems[1].selectedImage = UIImage(systemName: "person.3.sequence.fill")
                tabBarItems[1].image = UIImage(systemName: "person.3.sequence")
                tabBarItems[1].title = "Community"

                tabBarItems[2].selectedImage = UIImage(systemName: "gearshape.fill")
                tabBarItems[2].image = UIImage(systemName: "gearshape")
                tabBarItems[2].title = "Setting"
            }
        
        // 4. viewController로 window의 root view controller를 설정
        window.rootViewController = tabBarController
        
        // 5. window를 설정하고 makeKeyAndVisible()
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    
}

