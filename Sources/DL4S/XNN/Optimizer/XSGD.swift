//
//  XSGD.swift
//  DL4S
//
//  Created by Palle Klewitz on 19.10.19.
//

import Foundation

public struct XSGD<Layer: XLayer>: XOptimizer {
    public private(set) var model: Layer
    public var learningRate: XTensor<Layer.Parameter, Layer.Device>
    
    public init(model: Layer, learningRate: XTensor<Layer.Parameter, Layer.Device>) {
        self.model = model
        self.learningRate = learningRate
    }
    
    public mutating func update(along gradients: [XTensor<Layer.Parameter, Layer.Device>]) {
        for (keyPath, grad) in zip(Layer.parameters, gradients) {
            model[keyPath: keyPath] -= learningRate * grad
            model[keyPath: keyPath].discardContext()
        }
    }
}

public struct XMomentum<Layer: XLayer>: XOptimizer {
    public typealias ParamTensor = XTensor<Layer.Parameter, Layer.Device>
    
    public private(set) var model: Layer
    private var velocities: [ParamTensor]
    
    public var learningRate: ParamTensor
    public var momentum: ParamTensor
    private var paths: [WritableKeyPath<Layer, ParamTensor>]
    
    public init(model: Layer, learningRate: ParamTensor, momentum: ParamTensor = 0.8) {
        self.model = model
        self.learningRate = learningRate
        self.momentum = momentum
        
        self.velocities = model.parameters.map {
            XTensor(repeating: 0, shape: $0.shape)
        }
        self.paths = Layer.parameters
    }
    
    public mutating func update(along gradients: [ParamTensor]) {
        for i in paths.indices {
            let keyPath = paths[i]
            velocities[i] = velocities[i] * momentum + learningRate * gradients[i]
            model[keyPath: keyPath] -= velocities[i]
            model[keyPath: keyPath].discardContext()
        }
    }
}

extension XSGD: Codable where Layer: Codable {}

extension XMomentum: Codable where Layer: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        model = try container.decode(Layer.self, forKey: .model)
        momentum = try container.decode(ParamTensor.self, forKey: .momentum)
        learningRate = try container.decode(ParamTensor.self, forKey: .learningRate)
        velocities = try container.decode([ParamTensor].self, forKey: .velocities)
        
        paths = Layer.parameters
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(model, forKey: .model)
        try container.encode(momentum, forKey: .momentum)
        try container.encode(learningRate, forKey: .learningRate)
        try container.encode(velocities, forKey: .velocities)
    }
    
    private enum CodingKeys: String, CodingKey {
        case model
        case velocities
        case learningRate
        case momentum
    }
}