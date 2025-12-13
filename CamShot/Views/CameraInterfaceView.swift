//
//  CameraInterfaceView.swift
//  CamShot
//
//  Created by Adriano Oliviero on 12/12/25.
//

import SwiftUI

struct CameraInterfaceView: View {
    @State private var isZoomed: Bool = false

    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Text("0.5x")
                    .font(.headline)

                Toggle(isOn: $isZoomed) {}
                    .labelsHidden()

                Text("1x")
                    .font(.headline)
            }
            .padding(.top, 20)

            Spacer()

            HStack {
                Button {} label: {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.orange)
                        .padding(20)
                }
                .buttonStyle(.glass)
                .background(Circle().fill(.orange))

                Spacer()

                Button {} label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                        .padding(20)
                }
                .buttonStyle(.glass)
                .background(Circle().fill(.orange))
            }
            .padding(.horizontal, 40)

            Spacer()

            Button {} label: {
                ZStack {
//                    Circle()
//                        .fill(.red)
//                        .frame(width: 84, height: 84)

//                    Circle()
//                        .fill(.black)
//                        .frame(width: 72, height: 72)

                    Circle()
                        .fill(.white)
                        .frame(width: 60, height: 60)
                }
            }
            .padding(.bottom, 30)
            .buttonStyle(.glass)
//            .frame(width: 84, height: 84)
        }
    }
}

#Preview {
    CameraInterfaceView()
}
