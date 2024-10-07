import MetalKit

enum MOUSE_BUTTON_CODES: Int {
    case LEFT = 0
    case RIGHT = 1
    case CENTER = 2
}

class Mouse {
    private static var MOUSE_BUTTON_COUNT = 12
    private static var mouseButtonList = [Bool].init(repeating: false, count: MOUSE_BUTTON_COUNT)

    private static var overallMousePosition = SIMD2<Float>(repeating: 0)
    private static var mousePositionDelta = SIMD2<Float>(repeating: 0)

    private static var scrollWheelPositionY: Float = 0
    private static var lastWheelPositionY: Float = 0.0
    private static var scrollWheelChangeY: Float = 0.0
    
    private static var scrollWheelPositionX: Float = 0
    private static var lastWheelPositionX: Float = 0.0
    private static var scrollWheelChangeX: Float = 0.0

    public static func setMouseButtonPressed(button: Int, isOn: Bool){
        mouseButtonList[button] = isOn
    }

    public static func isMouseButtonPressed(button: MOUSE_BUTTON_CODES)->Bool{
        return mouseButtonList[Int(button.rawValue)] == true
    }

    public static func setOverallMousePosition(position: SIMD2<Float>){
        self.overallMousePosition = position
    }

    //Sets the delta distance the mouse had moved
        public static func setMousePositionChange(overallPosition: SIMD2<Float>, deltaPosition: SIMD2<Float>){
        self.overallMousePosition = overallPosition
        self.mousePositionDelta += deltaPosition
    }

    public static func scrollMouse(delta: SIMD2<Float>){
        scrollWheelPositionX += delta.x
        scrollWheelChangeX += delta.x
        
        scrollWheelPositionY += delta.y
        scrollWheelChangeY += delta.y
    }

    //Returns the overall position of the mouse on the current window
    public static func getMouseWindowPosition()->SIMD2<Float>{
        return overallMousePosition
    }

    //Returns the movement of the wheel since last time getDWheel() was called
    public static func getDWheelY()->Float{
        let position = scrollWheelChangeY
        scrollWheelChangeY = 0
        return position
    }
    
    public static func getDWheelX()->Float{
        let position = scrollWheelChangeX
        scrollWheelChangeX = 0
        return position
    }

    ///Movement on the y axis since last time getDY() was called.
    public static func getDY()->Float{
        let result = mousePositionDelta.y
        mousePositionDelta.y = 0
        return result
    }

    ///Movement on the x axis since last time getDX() was called.
    public static func getDX()->Float{
        let result = mousePositionDelta.x
        mousePositionDelta.x = 0
        return result
    }

    //Returns the mouse position in screen-view coordinates [-1, 1]
    public static func getMouseViewportPosition()->SIMD2<Float>{
        let x = (overallMousePosition.x - Renderer.screenSize.x * 0.5) / (Renderer.screenSize.x * 0.5)
        let y = (overallMousePosition.y - Renderer.screenSize.y * 0.5) / (Renderer.screenSize.y * 0.5)
        return SIMD2<Float>(x, y)
    }
}
