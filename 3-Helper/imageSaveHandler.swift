//
//  imageSaveHandler.swift
//  borderControl
//
//  Created by Dorian Benbassat on 2026/5/3.
//

import UIKit

final class ImageSaveHandler: NSObject {
    private let onComplete: (Result<Void, Error>) -> Void
    
    init(onComplete: @escaping (Result<Void, Error>) -> Void) {
        self.onComplete = onComplete
    }
    
    @objc func image(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer
    ) {
        if let error {
            onComplete(.failure(error))
        } else {
            onComplete(.success(()))
        }
    }
}
