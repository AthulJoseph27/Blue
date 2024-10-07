import SwiftUI

struct Sidebar: View {
    @ObservedObject var contentData: ContentViewModel
    
    var body: some View {
        VStack {
            TabButton(image: "rectangle.grid.2x2", title: "Ray Tracing", tab: .RayTracing, selectedTab: $contentData.selectedTab)
            TabButton(image: "rectangle.grid.2x2", title: "Vertex Shader", tab: .VertexShader, selectedTab: $contentData.selectedTab)
            Spacer()
            TabButton(image: "camera", title: "Render Image", tab: .RenderImage, selectedTab: $contentData.selectedTab)
            TabButton(image: "video", title: "Render Animation", tab: .RenderAnimation, selectedTab: $contentData.selectedTab)
            Spacer()
            TabButton(image: "gear", title: "Settings", tab: .Settings, selectedTab: $contentData.selectedTab)
        }
        .padding()
        .padding(.top, 36)
        .background(BlurView())
        .frame(width: 100)
    }
}
