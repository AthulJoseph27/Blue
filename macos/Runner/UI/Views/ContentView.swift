import SwiftUI
import CoreData
import MetalKit

var screen = NSScreen.main!.visibleFrame
var gameViewController: NSViewController!
var gameStoryboard: NSStoryboard!

struct ContentView: View {
    @StateObject var contentData = ContentViewModel()
    @State var showSplashScreen = true
    var flutterView: WindowViewController
    var PSView: MetalView
    
    init() {
        flutterView = FlutterView.flutterView
        PSView = RendererManager.getMetalView(.PhongShader)
    }
    
    var body: some View {
        if showSplashScreen {
            flutterView.onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.showSplashScreen = false
                }
            }
        } else {
            ZStack {
                
                switch contentData.selectedTab {
                    
                case .RayTracing:
                    RendererManager.getMetalView(RendererManager.currentRTViewPortType).edgesIgnoringSafeArea(.all)
                    
                case .VertexShader:
                                     PSView
                                         .edgesIgnoringSafeArea(.all)
                    
                default:
                    flutterView
                }
                
                HStack() {
                    Spacer()
                    
                    Sidebar(contentData: contentData)
                        .frame(width: 100)
                        .offset(x: contentData.showSideBar ? 0 : 120)
                    
                }
                
                HStack {
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        
                        Button(action: {withAnimation{ contentData.showSideBar.toggle() }}, label: {
                            
                            Image(systemName: "sidebar.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.blue)
                            
                        })
                        .padding(.all, 12)
                        .buttonStyle(PlainButtonStyle())
                        .opacity((contentData.showDrawerButton || contentData.showSideBar || !(contentData.selectedTab == .RayTracing || contentData.selectedTab == .VertexShader)) ? 1 : 0)
                        .onHover{ hover in
                            withAnimation {
                                contentData.showDrawerButton = hover
                            }
                        }
                        
                        Spacer()
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all, edges: .all)
            .onChange(of: contentData.selectedTab) { value in
                if contentData.selectedTab != .RayTracing && contentData.selectedTab != .VertexShader {
                    RendererManager.pauseAllRenderingLoop()
                }
                
                if contentData.selectedTab == .RayTracing {
                    RendererManager.updateViewPort(viewPortType: RendererManager.currentRTViewPortType)
                } else if contentData.selectedTab == .VertexShader{
                    RendererManager.updateViewPort(viewPortType: .PhongShader)
                }
            }
            
        }
        
    }
}
