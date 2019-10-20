//
//  CPUInt32.swift
//  DL4S
//
//  Created by Palle Klewitz on 20.10.19.
//

import Foundation
#if canImport(Accelerate)
import Accelerate
#endif


extension Int32: CPUNumeric {
    public static func fill(value: Int32, result: UnsafeMutableBufferPointer<Int32>, stride: Int, count: Int) {
        vDSP_vfilli([value], result.pointer(capacity: count), stride, UInt(count))
    }
    
    public static func tanh(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        fatalError("Tanh not implemented for Int32")
    }
    
    public static func relu(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = Swift.max(0, val[i])
        }
    }
    
    public static func transpose(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, srcRows: Int, srcCols: Int) {
        for x in 0 ..< srcCols {
            for y in 0 ..< srcRows {
                result[y + x * srcRows] = val[y * srcCols + x]
            }
        }
    }
    
    public static func vsAdd(lhs: UnsafeBufferPointer<Int32>, rhs: Int32, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        vDSP_vsaddi(lhs.pointer(capacity: count), 1, [rhs], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vsMul(lhs: UnsafeBufferPointer<Int32>, rhs: Int32, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = lhs[i] * rhs
        }
    }
    
    public static func svDiv(lhs: Int32, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = lhs / rhs[i]
        }
    }
    
    public static func fill(value: Int32, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        vDSP_vfilli([value], result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func log(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = Int32(Foundation.log(Float(val[i])))
        }
    }
    
    public static func exp(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = Int32(Foundation.exp(Float(val[i])))
        }
    }
    
    public static func sqrt(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = Int32(Foundation.sqrt(Float(val[i])))
        }
    }
    
    public static func vSub(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = lhs[i] - rhs[i]
        }
    }
    
    public static func vMul(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = lhs[i] * rhs[i]
        }
    }
    
    public static func vDiv(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = lhs[i] * rhs[i]
        }
    }
    
    public static func vAdd(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        vDSP_vaddi(lhs.pointer(capacity: count), 1, rhs.pointer(capacity: count), 1, result.pointer(capacity: count), 1, UInt(count))
    }
    
    public static func vNeg(val: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        for i in 0 ..< count {
            result[i] = -val[i]
        }
    }
    
    public static func sum(val: UnsafeBufferPointer<Int32>, count: Int) -> Int32 {
        var result: Int32 = 0
        for i in 0 ..< count {
            result += val[i]
        }
        return result
    }
    
    public static func sum(val: UnsafeBufferPointer<Int32>, stride: Int, count: Int) -> Int32 {
        var result: Int32 = 0
        for i in 0 ..< count {
            result += val[i * stride]
        }
        return result
    }
    
    public static func gemm(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, lhsShape: (Int, Int), rhsShape: (Int, Int), resultShape: (Int, Int), alpha: Int32, beta: Int32, transposeFirst: Bool, transposeSecond: Bool) {
        precondition((transposeFirst ? lhsShape.1 : lhsShape.0) == resultShape.0)
        precondition((transposeSecond ? rhsShape.0 : rhsShape.1) == resultShape.1)
        precondition((transposeFirst ? lhsShape.0 : lhsShape.1) == (transposeSecond ? rhsShape.1 : rhsShape.0))
        
        cblas_igemm(
            CblasRowMajor,
            transposeFirst ? CblasTrans : CblasNoTrans,
            transposeSecond ? CblasTrans : CblasNoTrans,
            Int32(resultShape.0),
            Int32(resultShape.1),
            Int32(transposeFirst ? lhsShape.0 : lhsShape.1),
            alpha,
            lhs.pointer(capacity: lhsShape.0 * lhsShape.1),
            Int32(lhsShape.1),
            rhs.pointer(capacity: rhsShape.0 * rhsShape.1),
            Int32(rhsShape.1),
            beta,
            result.pointer(capacity: resultShape.0 * resultShape.1),
            Int32(resultShape.1)
        )
    }
    
    public static func argmax(values: UnsafeBufferPointer<Int32>, count: Int) -> (Int, Int32) {
        precondition(count > 0)
        var maxI = 0
        var maxV = values[0]
        
        for i in 0 ..< count {
            if maxV < values[i] {
                maxI = i
                maxV = values[i]
            }
        }
        
        return (maxI, maxV)
    }
    
    public static func argmax(values: UnsafeBufferPointer<Int32>, stride: Int, count: Int) -> (Int, Int32) {
        precondition(count > 0)
        var maxI = 0
        var maxV = values[0]
        
        for i in 0 ..< count {
            let v = values[i * stride]
            if maxV < v {
                maxI = i
                maxV = v
            }
        }
        
        return (maxI, maxV)
    }
    
    public static func argmin(values: UnsafeBufferPointer<Int32>, stride: Int, count: Int) -> (Int, Int32) {
        precondition(count > 0)
        var minI = 0
        var minV = values[0]
        
        for i in 0 ..< count {
            let v = values[i * stride]
            if minV > v {
                minI = i
                minV = v
            }
        }
        
        return (minI, minV)
    }
    
    public static func argmin(values: UnsafeBufferPointer<Int32>, count: Int) -> (Int, Int32) {
        precondition(count > 0)
        var minI = 0
        var minV = values[0]
        
        for i in 0 ..< count {
            if minV > values[i] {
                minI = i
                minV = values[i]
            }
        }
        
        return (minI, minV)
    }
    
    public static func copy(values: UnsafeBufferPointer<Int32>, srcStride: Int, result: UnsafeMutableBufferPointer<Int32>, dstStride: Int, count: Int) {
        let srcPtr = values.pointer(capacity: srcStride * count)
        let dstPtr = result.pointer(capacity: dstStride * count)
        
        for i in 0 ..< count {
            dstPtr[i * dstStride] = srcPtr[i * srcStride]
        }
    }
    
    public static func arange(start: Int32, end: Int32, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        let ptr = result.pointer(capacity: count)
        for i in 0 ..< Int32(count) {
            ptr[Int(i)] = start + (end - start) * Int32(count) / i
        }
    }
    
    public static func max(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        let lhsPtr = lhs.pointer(capacity: count)
        let rhsPtr = rhs.pointer(capacity: count)
        let resPtr = result.pointer(capacity: count)
        
        for i in 0 ..< count {
            resPtr[i] = Swift.max(lhsPtr[i], rhsPtr[i])
        }
    }
    
    public static func min(lhs: UnsafeBufferPointer<Int32>, rhs: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        let lhsPtr = lhs.pointer(capacity: count)
        let rhsPtr = rhs.pointer(capacity: count)
        let resPtr = result.pointer(capacity: count)
        
        for i in 0 ..< count {
            resPtr[i] = Swift.min(lhsPtr[i], rhsPtr[i])
        }
    }
    
    public static func sin(values: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        fatalError("\(#function) is unavailable for type \(Self.self)")
    }
    
    public static func cos(values: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        fatalError("\(#function) is unavailable for type \(Self.self)")
    }
    
    public static func tan(values: UnsafeBufferPointer<Int32>, result: UnsafeMutableBufferPointer<Int32>, count: Int) {
        fatalError("\(#function) is unavailable for type \(Self.self)")
    }
}
