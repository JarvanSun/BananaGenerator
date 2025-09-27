import Foundation
import Photos
import PhotosUI

/// Utility for saving images to the photo library
enum PhotoSaver {
    /// Saves an image from the given URL to the photo library
    static func saveImage(at url: URL) async throws {
        try await requestAddOnlyIfNeeded()
        try await PHPhotoLibrary.shared().performChanges {
            let req = PHAssetCreationRequest.forAsset()
            req.addResource(with: .photo, fileURL: url, options: nil)
        }
    }
    
    /// Requests photo library add-only permission if not already granted
    private static func requestAddOnlyIfNeeded() async throws {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized || status == .limited { return }
        let granted = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard granted == .authorized || granted == .limited else {
            throw PhotoSaverError.permissionDenied
        }
    }
}

// MARK: - Error
enum PhotoSaverError: LocalizedError {
    case permissionDenied
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "No permission to save to photo library"
        }
    }
}