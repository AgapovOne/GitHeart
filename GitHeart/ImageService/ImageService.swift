//
//  ImageService.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 29.06.2021.
//

import UIKit

/// Responsible for requesting and providing an image by its url.
class ImageService {
    private let session: URLSession
    private let cache: MemoryCache<URL, Data>

    init(session: URLSession, cache: MemoryCache<URL, Data>) {
        self.session = session
        self.cache = cache
    }
}

extension ImageService: ImageProvider {
    func imageBy(url: URL, completion: @escaping (UIImage?) -> Void) -> ImageProviderTask? {
        if let data = cache.value(forKey: url), let image = UIImage(data: data) {
            completion(image)
            return nil
        } else {
            let task = session.dataTask(with: url) { [weak self] data, _, error in
                if let error = error {
                    if (error as NSError).code == NSURLErrorCancelled {
                        return
                    }
                    DispatchQueue.main.async {
                        print("ImageService: failed to download image: \(url)\nError: \(error)")
                        completion(nil)
                    }

                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self?.cache.set(value: data, for: url)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    DispatchQueue.main.async {
                        print("ImageService: failed to decode image")
                        completion(nil)
                    }
                }
            }
            task.resume()
            return task
        }
    }
}

extension URLSessionTask: ImageProviderTask {}
