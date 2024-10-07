import SwiftUI

struct MetalView: NSViewControllerRepresentable {
    var viewPortType: RenderViewPortType?
    var gameViewController: GameViewController?
    
    init(_ viewPortType: RenderViewPortType) {
        self.viewPortType = viewPortType
    }
    
    init(_ gameViewController: GameViewController) {
        self.gameViewController = gameViewController
    }
    
    func makeNSViewController(context: Context) -> NSViewController {
        if gameViewController != nil {
            return gameViewController!
        }
        return RendererManager.getGameViewController(viewPortType!)
    }

    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
    }
}

