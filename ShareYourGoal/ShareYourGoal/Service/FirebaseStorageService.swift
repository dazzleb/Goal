//
//  FirebaseStorageService.swift
//  ShareYourGoal
//
//  Created by 시혁 on 2023/08/07.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import RxSwift

final class FirebaseStorageService {
    
    static let shared = FirebaseStorageService()
    let storage = Storage.storage(url: "gs://goal-fb400.appspot.com")
    
    /// 프로필 이미지 업로드하기
    /// - Parameters:
    ///   - data: 업로드할 이미지 데이터
    ///   - completion: 업로된 이미지 주소
    func uploadProfileImg(userUid: String,
                          data: Data) -> Observable<String> {
        // Create a root reference
        // 스토리지의 루트 레퍼런스를 생성
        let storageRef = storage.reference()
        
        // Create a reference to "mountains.jpg"
        // 이미지 파일 이름을 생성
        let now = Date()
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        
        // 현재 시간으로 만들기
        let imageName = formatter1.string(from: now)  + ".jpg"
        
        // Create a reference to 'images/mountains.jpg'
        // 이미지를 저장할 경로를 생성
        let imagesRef = storageRef.child("/users/profiles/\(userUid)/\(imageName)")
        
        // Data in memory
        //  업로드 동작을 정의하고, 업로드 상태를 옵저버에게 알려줍니다
        return Observable.create { observer in
            // Upload the file to the path "images/rivers.jpg"
            //이미지 데이터를 지정한 경로에 업로드
            let uploadTask = imagesRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    observer.on(.next(nil))
                    return
                }
//                metadata.contentType = "image/jpeg"
                // Metadata contains file metadata such as size, content-type.
                
                
                // 업로드된 파일의 크기 정보 가져오기
                let size = metadata.size
                // You can also access to download URL after upload.
                //업로드된 파일의 다운로드 URL
                imagesRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        observer.on(.next(nil))
                        return
                    }
                    // 문자열로 변환
                    let profileImgUrlString = downloadURL.absoluteString
                    // 프로필 이미지의 URL을 전달
                    observer.on(.next(profileImgUrlString))
                    observer.on(.completed)
                }
                
            }
            return Disposables.create()
        }.compactMap{ $0 } // nil 값을 제외하고 반환

    }
    
}
