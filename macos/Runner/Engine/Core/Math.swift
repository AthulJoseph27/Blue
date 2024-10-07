import MetalKit

public var X_AXIS: SIMD3<Float> {
    return SIMD3<Float>(1,0,0)
}

public var Y_AXIS: SIMD3<Float> {
    return SIMD3<Float>(0,1,0)
}

public var Z_AXIS: SIMD3<Float> {
    return SIMD3<Float>(0,0,1)
}

extension Float {
    var toRadian: Float {
        return (self / 180.0) * Float.pi
    }
    
    var toDegree: Float {
        return (self / Float.pi) * 180.0
    }
}

extension SIMD3<Float> {
    func simd4(w: Float)->SIMD4<Float> {
        return SIMD4<Float>(x, y, z, w)
    }
}

extension SIMD4<Float> {
    var xyz: SIMD3<Float> {
        return SIMD3<Float>(x, y, z)
    }
}

//extension SIMD3<Float> {
//    mutating func rotateVector(vector: SIMD3<Float>, axis: SIMD3<Float>, angle: Float) {
//        
//        // Create a quaternion with the angle and axis.
//        let quaternion = simd_quatf(angle: angle, axis: axis)
//        
//        // Apply the quaternion to the vector.
//        let rotatedVector = quaternion.act(vector)
//        
//        // Return the rotated vector.
//        self = rotatedVector
//    }
//}

extension matrix_float4x4 {
    mutating func translate(direction: SIMD3<Float>) {
        var operation = matrix_identity_float4x4
        
        operation.columns = (
            SIMD4<Float>(1, 0, 0, 0),
            SIMD4<Float>(0, 1, 0, 0),
            SIMD4<Float>(0, 0, 1, 0),
            SIMD4<Float>(direction.x, direction.y, direction.z, 1)
        )
        
        self = matrix_multiply(self, operation)
    }
    
    mutating func scale(axis: SIMD3<Float>) {
        var operation = matrix_identity_float4x4
        
        operation.columns = (
            SIMD4<Float>(axis.x, 0, 0, 0),
            SIMD4<Float>(0, axis.y, 0, 0),
            SIMD4<Float>(0, 0, axis.z, 0),
            SIMD4<Float>(0, 0, 0, 1)
        )
        
        self = matrix_multiply(self, operation);
    }
    
    mutating func rotate(angle: Float, axis: SIMD3<Float>) {
        var operation = matrix_identity_float4x4
        
        let x: Float = axis.x
        let y: Float = axis.y
        let z: Float = axis.z
        
        let c: Float = cos(angle)
        let s: Float = sin(angle)
        
        let mc: Float = (1 - c)
        
        let r1c1: Float = x * x * mc + c
        let r2c1: Float = x * y * mc + z * s
        let r3c1: Float = x * z * mc - y * s
        let r4c1: Float = 0.0
        
        let r1c2: Float = y * x * mc - z * s
        let r2c2: Float = y * y * mc + c
        let r3c2: Float = y * z * mc + x * s
        let r4c2: Float = 0.0

        
        let r1c3: Float = z * x * mc + y * s
        let r2c3: Float = z * y * mc - x * s
        let r3c3: Float = z * z * mc + c
        let r4c3: Float = 0.0
        
        let r1c4: Float = 0.0
        let r2c4: Float = 0.0
        let r3c4: Float = 0.0
        let r4c4: Float = 1.0

        
        operation.columns = (
            SIMD4<Float>(r1c1, r2c1, r3c1, r4c1),
            SIMD4<Float>(r1c2, r2c2, r3c2, r4c2),
            SIMD4<Float>(r1c3, r2c3, r3c3, r4c3),
            SIMD4<Float>(r1c4, r2c4, r3c4, r4c4)
        )
        
        self = matrix_multiply(self, operation);
    }
    
    static func prespective(degreeFov: Float, aspectRatio: Float, near: Float, far: Float)->matrix_float4x4 {
        let fov = degreeFov.toRadian
        
        let t: Float = tan(fov / 2.0)
        
        let x: Float = 1 / (aspectRatio * t)
        let y: Float = 1 / t
        let z: Float = -((far + near) / (far - near))
        let w: Float = -((2 * far * near) / (far - near))
        
        var result = matrix_identity_float4x4
        
        result.columns = (
            SIMD4<Float>(x, 0, 0, 0),
            SIMD4<Float>(0, y, 0, 0),
            SIMD4<Float>(0, 0, z, -1),
            SIMD4<Float>(0, 0, w, 0)
        )
        
        return result
    }
    
    static func lookAt(position: SIMD3<Float>, target: SIMD3<Float>, up: SIMD3<Float>) -> float4x4 {
        var viewMatrix = float4x4()

        let z = normalize(target - position)
        let x = normalize(cross(up, z))
        let y = cross(z, x)

        viewMatrix[0, 0] = x.x
        viewMatrix[1, 0] = x.y
        viewMatrix[2, 0] = x.z
        viewMatrix[3, 0] = -dot(x, position)

        viewMatrix[0, 1] = y.x
        viewMatrix[1, 1] = y.y
        viewMatrix[2, 1] = y.z
        viewMatrix[3, 1] = -dot(y, position)

        viewMatrix[0, 2] = z.x
        viewMatrix[1, 2] = z.y
        viewMatrix[2, 2] = z.z
        viewMatrix[3, 2] = -dot(z, position)

        viewMatrix[0, 3] = 0
        viewMatrix[1, 3] = 0
        viewMatrix[2, 3] = 0
        viewMatrix[3, 3] = 1

        return viewMatrix
    }
    
    static func perspective(fieldOfView: Float, aspectRatio: Float, nearZ: Float, farZ: Float) -> float4x4 {
        var perspectiveMatrix = float4x4()

        let yScale = 1.0 / tan(fieldOfView * 0.5)
        let xScale = yScale / aspectRatio
        let zRange = farZ - nearZ

        perspectiveMatrix[0, 0] = xScale
        perspectiveMatrix[1, 1] = yScale
        perspectiveMatrix[2, 2] = -(farZ + nearZ) / zRange
        perspectiveMatrix[2, 3] = -1.0
        perspectiveMatrix[3, 2] = -2.0 * nearZ * farZ / zRange
        perspectiveMatrix[3, 3] = 0.0

        return perspectiveMatrix
    }
}
