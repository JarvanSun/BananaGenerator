import SwiftUI
import Photos
import PhotosUI

/// Photo item containing both thumbnail and asset reference
struct PhotoItem {
    let thumbnail: UIImage
    let asset: PHAsset
}

/// Manager for handling photo library access and recent photos
@Observable
final class PhotosManager {
    static let shared = PhotosManager()
    
    // Published properties for UI updates
    var recentPhotoItems: [PhotoItem] = []
    var authorizationStatus: PHAuthorizationStatus = .notDetermined
    var isLoading = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    /// Check current photo library authorization status
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    /// Request photo library access if needed
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
        return status == .authorized || status == .limited
    }
    
    /// Load recent photos from the photo library (only if already authorized)
    func loadRecentPhotosIfAuthorized(count: Int = 6) async {
        // Only proceed if we already have permission
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            return
        }
        
        await loadPhotosFromLibrary(count: count)
    }
    
    /// Load recent photos from the photo library with permission request
    func loadRecentPhotos(count: Int = 6) async {
        // Check if we have permission, request if needed
        if authorizationStatus != .authorized && authorizationStatus != .limited {
            let authorized = await requestAuthorization()
            guard authorized else { 
                return 
            }
        }
        
        await loadPhotosFromLibrary(count: count)
    }
    
    /// Internal method to load photos from library
    private func loadPhotosFromLibrary(count: Int) async {
        await MainActor.run {
            self.isLoading = true
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = count
        
        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        
        // Target size for thumbnails (retina display)
        let targetSize = CGSize(width: 200, height: 200)
        
        // Collect images and assets in a thread-safe way
        let collectedItems = await withCheckedContinuation { continuation in
            var items: [PhotoItem] = []
            var processedCount = 0
            
            fetchResult.enumerateObjects { asset, _, stop in
                imageManager.requestImage(
                    for: asset,
                    targetSize: targetSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    if let image = image {
                        let photoItem = PhotoItem(thumbnail: image, asset: asset)
                        items.append(photoItem)
                    }
                    processedCount += 1
                    // Check if this is the last asset
                    if processedCount == fetchResult.count {
                        continuation.resume(returning: items)
                    }
                }
            }
            
            // Handle case with no assets
            if fetchResult.count == 0 {
                continuation.resume(returning: items)
            }
        }
        
        await MainActor.run {
            self.recentPhotoItems = collectedItems
            self.isLoading = false
        }
    }
    
    /// Convert PHAsset to UIImage for full resolution
    func loadFullImage(from asset: PHAsset) async -> UIImage? {
        await withCheckedContinuation { continuation in
            let imageManager = PHImageManager.default()
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            
            imageManager.requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}