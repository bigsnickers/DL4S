//
//  XSequential.swift
//  DL4S
//
//  Created by Palle Klewitz on 16.10.19.
//  Copyright (c) 2019 - Palle Klewitz
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

public struct XSequential<First: XLayer, Second: XLayer>: XLayer where First.Outputs == Second.Inputs, First.Parameter == Second.Parameter, First.Device == Second.Device {
    public var first: First
    public var second: Second
    
    public var tag: String? = nil
    
    public var parameters: [XTensor<First.Parameter, First.Device>] {
        get {
            first.parameters + second.parameters
        }
        set {
            let c = first.parameters.count
            first.parameters = Array(newValue[..<c])
            second.parameters = Array(newValue[c...])
        }
    }
    
    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }
    
    public static var parameters: [WritableKeyPath<XSequential<First, Second>, XTensor<First.Parameter, First.Device>>] {
        First.parameters.map((\Self.first).appending(path:)) +
            Second.parameters.map((\Self.second).appending(path:))
    }
    
    public func callAsFunction(_ inputs: First.Inputs) -> Second.Outputs {
        if let tag = self.tag {
            return OperationGroup.capture(named: tag) {
                second.callAsFunction(first.callAsFunction(inputs))
            }
        } else {
            return second.callAsFunction(first.callAsFunction(inputs))
        }
    }
}

extension XSequential: Codable where First: Codable, Second: Codable {}

@_functionBuilder
public struct LayerBuilder {}

public extension LayerBuilder {
    static func buildBlock<A, B>(_ a: A, _ b: B) -> XSequential<A, B>
        where A.Outputs == B.Inputs, A.Parameter == B.Parameter, A.Device == B.Device
    {
        XSequential(first: a, second: b)
    }
    
    static func buildBlock<A, B, C>(_ a: A, _ b: B, _ c: C) -> XSequential<XSequential<A, B>, C> {
        buildBlock(buildBlock(a, b), c)
    }
    
    static func buildBlock<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) -> XSequential<XSequential<A, B>, XSequential<C, D>> {
        buildBlock(buildBlock(a, b), buildBlock(c, d))
    }
    
    static func buildBlock<A, B, C, D, E>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> XSequential<XSequential<XSequential<A, B>, C>, XSequential<D, E>> {
        buildBlock(buildBlock(a, b, c), buildBlock(d, e))
    }
    
    static func buildBlock<A, B, C, D, E, F>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F) -> XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<E, F>> {
        buildBlock(buildBlock(a, b, c, d), buildBlock(e, f))
    }
    
    static func buildBlock<A, B, C, D, E, F, G>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G) -> XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, G>> {
        buildBlock(buildBlock(a, b, c, d), buildBlock(e, f, g))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H) -> XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>> {
        buildBlock(buildBlock(a, b, c, d), buildBlock(e, f, g, h))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, I> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), i)
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<I, J>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<I, J>, K>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K, L>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K, _ l: L) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<I, J>, XSequential<K, L>>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k, l))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K, L, M>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K, _ l: L, _ m: M) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<XSequential<I, J>, K>, XSequential<L, M>>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k, l, m))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K, L, M, N>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K, _ l: L, _ m: M, _ n: N) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<XSequential<I, J>, XSequential<K, L>>, XSequential<M, N>>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k, l, m, n))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K, _ l: L, _ m: M, _ n: N, _ o: O) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<XSequential<I, J>, XSequential<K, L>>, XSequential<XSequential<M, N>, O>>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k, l, m, n, o))
    }
    
    static func buildBlock<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E, _ f: F, _ g: G, _ h: H, _ i: I, _ j: J, _ k: K, _ l: L, _ m: M, _ n: N, _ o: O, _ p: P) -> XSequential<XSequential<XSequential<XSequential<A, B>, XSequential<C, D>>, XSequential<XSequential<E, F>, XSequential<G, H>>>, XSequential<XSequential<XSequential<I, J>, XSequential<K, L>>, XSequential<XSequential<M, N>, XSequential<O, P>>>> {
        buildBlock(buildBlock(a, b, c, d, e, f, g, h), buildBlock(i, j, k, l, m, n, o, p))
    }
}

public extension XSequential {
    init(@LayerBuilder _ build: () -> Self) {
        self = build()
    }
}