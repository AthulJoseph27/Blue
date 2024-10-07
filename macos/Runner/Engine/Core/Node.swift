import MetalKit

enum TransformOrder {
    case TranslateScaleRotate
    case RotateTranslateScale
    case RotateScaleTranslate
}

class Node {
    var transformOrder: TransformOrder = .TranslateScaleRotate
    var position: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    var scale: SIMD3<Float> = SIMD3<Float>(repeating: 1)
    var rotation: SIMD3<Float> = SIMD3<Float>(repeating: 0)
    
    var modelMatrix: matrix_float4x4 {
       return generateModelMatrix()
    }
    
    func update(deltaTime: Float) {}
    
    private func generateModelMatrix() -> matrix_float4x4 {
        var modelMatrix = matrix_identity_float4x4
        
        if transformOrder == .TranslateScaleRotate {
            modelMatrix.translate(direction: position)
            modelMatrix.scale(axis: scale)
            modelMatrix.rotate(angle: rotation.x, axis: X_AXIS)
            modelMatrix.rotate(angle: rotation.y, axis: Y_AXIS)
            modelMatrix.rotate(angle: rotation.z, axis: Z_AXIS)
            return modelMatrix
        }
        
        if transformOrder == .RotateScaleTranslate {
            modelMatrix.rotate(angle: rotation.x, axis: X_AXIS)
            modelMatrix.rotate(angle: rotation.y, axis: Y_AXIS)
            modelMatrix.rotate(angle: rotation.z, axis: Z_AXIS)
            modelMatrix.scale(axis: scale)
            modelMatrix.translate(direction: position)
            return modelMatrix
        }
        
        modelMatrix.rotate(angle: rotation.x, axis: X_AXIS)
        modelMatrix.rotate(angle: rotation.y, axis: Y_AXIS)
        modelMatrix.rotate(angle: rotation.z, axis: Z_AXIS)
        modelMatrix.translate(direction: position)
        modelMatrix.scale(axis: scale)
        return modelMatrix
        
    }
}
