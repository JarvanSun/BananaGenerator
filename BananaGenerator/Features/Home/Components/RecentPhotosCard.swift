import SwiftUI
import Photos
import PhotosUI

/// Recent photos grid component showing 2x3 grid of user's photos
/// Inspired by Grok Imagine interface
struct RecentPhotosCard: View {
    let onPhotoSelected: (UIImage, Template) -> Void
    @State private var containerSize: CGSize = .zero
    @State private var photosManager = PhotosManager.shared
    
    @State private var showingPermissionDenied = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingPhotoPicker = false
    @State private var hasRequestedPermission = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3),
        GridItem(.flexible(), spacing: 3)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            
            // Photos grid
            Group {
                if photosManager.authorizationStatus == .notDetermined && !hasRequestedPermission {
                    notDeterminedView
                } else if photosManager.authorizationStatus == .denied {
                    permissionDeniedView
                } else if photosManager.isLoading {
                    loadingView
                } else if photosManager.recentPhotoItems.isEmpty {
                    emptyStateView
                } else {
                    photosGrid
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
            )
            .onSizeChange { newSize in
                containerSize = newSize
            }
        }
        .task {
            // Only check authorization status, don't request permission
            photosManager.checkAuthorizationStatus()
            
            // Load photos only if already authorized
            if photosManager.authorizationStatus == .authorized ||
               photosManager.authorizationStatus == .limited {
                await photosManager.loadRecentPhotosIfAuthorized()
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("Recent Photos")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            if photosManager.authorizationStatus == .denied {
                Button(action: {
                    openSettings()
                }) {
                    Text("Enable")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            } else {
                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("See All")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .onChange(of: selectedPhotoItem) { _ , newValue in
                    Task {
                        guard let item = newValue,
                           let data = try? await item.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data),
                           let firstTemplate = Template.allTemplates.first
                        else {
                            return
                        }
                        
                        // Navigate to generation with selected photo
                        onPhotoSelected(uiImage, firstTemplate)
                    }
                }
            }
        }
    }
    
    private var photosGrid: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(Array(photosManager.recentPhotoItems.prefix(6).enumerated()), id: \.offset) { index, photoItem in
                photoThumbnail(photoItem: photoItem, index: index)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var loadingView: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(0..<6) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var emptyStateView: some View {
        LazyVGrid(columns: columns, spacing: 3) {
            ForEach(0..<6) { _ in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.3))
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var permissionDeniedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.5))
            
            Text("Photo Access Required")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("Enable photo access in Settings to use your recent photos")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var notDeterminedView: some View {
        ZStack {
            // Background grid of placeholder images
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(0..<6) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.2))
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Gradient blur overlay
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0),
                    Color.black.opacity(0.2),
                    Color.black.opacity(0.5)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // Bottom content
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Select Photo to Generate Effect")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        Task {
                            hasRequestedPermission = true
                            await photosManager.loadRecentPhotos()
                        }
                    }) {
                        Text("Continue")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                            )
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    private func photoThumbnail(photoItem: PhotoItem, index: Int) -> some View {
        Button(action: {
            Task {
                // Load full resolution image from PHAsset
                if let fullImage = await photosManager.loadFullImage(from: photoItem.asset),
                   let firstTemplate = Template.allTemplates.first {
                    // Navigate to generation with full resolution photo
                    onPhotoSelected(fullImage, firstTemplate)
                }
            }
        }) {
            Image(uiImage: photoItem.thumbnail)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    HomeView()
}


#Preview {
    RecentPhotosCard(onPhotoSelected: { image, template in
        print("Photo selected with template: \(template.name)")
    })
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
