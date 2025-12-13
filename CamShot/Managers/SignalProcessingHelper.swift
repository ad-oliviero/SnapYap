//
//  SignalProcessingHelper.swift
//  CamShot
//
//  Created by Adriano Oliviero on 11/12/25.
//

import Accelerate
import AVKit

struct AudioInfo: Sendable {
    let sampleRate: Double
    let duration: Double
    let samples: [Float]
}

enum SignalProcessingHelper {
    static func samples(_ asset: AVURLAsset) throws -> AudioInfo? {
        let audio = try AVAudioFile(forReading: asset.url)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: audio.processingFormat, frameCapacity: UInt32(audio.length)) else { return nil }
        try audio.read(into: buffer)
        guard let channel = buffer.floatChannelData else { return nil }
        let samples = Array(
            UnsafeBufferPointer(
                start: channel[0], count: Int(buffer.frameLength)
            )
        )
        
        return .init(
            sampleRate: audio.processingFormat.sampleRate,
            duration: Double(audio.length) / audio.processingFormat.sampleRate,
            samples: samples
        )
    }
    
    static func downsample(_ samples: [Float], count: Int) async throws -> [Float] {
        guard !samples.isEmpty else { return [] }
        
        let total = samples.count
        let chunkSize = max(samples.count / count, 1)
        var newSamples = [Float](repeating: 0, count: count)
        
        for i in 0..<count {
            let start = i * chunkSize
            let end = min(start + chunkSize, total)
            
            if start < end {
                samples.withUnsafeBufferPointer { buffer in
                    let slice = buffer[start..<end]
                    newSamples[i] = vDSP.maximum(slice)
                }
            }
        }
        
        return newSamples
    }
}
