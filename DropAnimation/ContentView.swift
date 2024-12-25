//
//  ContentView.swift
//  DropAnimation
//
//  Created by Irina Deeva on 25/12/24.
//

import SwiftUI

struct ContentView: View {
  @State private var offset: CGSize = .zero
  @State private var isDragging: Bool = false

  var body: some View {
    Rectangle()
      .fill(.yellow)
      .mask(canvas)
      .overlay{
          Circle()
            .fill(dynamicColor)
            .frame(width: 100, height: 100)
            .offset(offset)
      }
      .gesture(
        DragGesture()
          .onChanged { gesture in
            offset = gesture.translation
            isDragging = true
          }
          .onEnded { _ in
            withAnimation(.interpolatingSpring(stiffness: 50, damping: 10)) {
              offset = .zero
              isDragging = false
            }
          }
      )
      .overlay(
        Image(systemName: "cloud.sun.rain.fill")
          .font(.title)
          .foregroundColor(.white)
          .offset(offset)
      )
      .background(.white)
  }

  var dynamicColor: Color {
      let maxOffset: CGFloat = 200
      let distance = min(sqrt(offset.width * offset.width + offset.height * offset.height), maxOffset)
      let progress = distance / maxOffset
      return Color.yellow.interpolate(to: Color.red, fraction: progress)
  }

  var canvas: some View {
    Canvas()    { context,size in
      let firstCircle = context.resolveSymbol(id: 1)!
      let secondCircle = context.resolveSymbol(id: 2)!

      context.addFilter(.alphaThreshold(min: 0.4, color: .yellow))
      context.addFilter(.blur(radius: 10))
      context.drawLayer{
        drawingContext in
        let drawPoint = CGPoint(x: size.width / 2, y: size.height/2)
        drawingContext.draw(firstCircle, at: drawPoint)
        drawingContext.draw(secondCircle, at: drawPoint)
      }
    } symbols: {
      Circle()
        .frame(width: 100, height: 100)
        .tag(1)
      Circle()
        .frame(width: 100, height: 100)
        .offset(offset)
        .tag(2)
    }
  }
}

#Preview {
  ContentView()
}

extension Color {
    func interpolate(to color: Color, fraction: CGFloat) -> Color {
        let f = min(max(0, fraction), 1)
        let fromComponents = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let toComponents = UIColor(color).cgColor.components ?? [0, 0, 0, 1]

        let r = fromComponents[0] + (toComponents[0] - fromComponents[0]) * f
        let g = fromComponents[1] + (toComponents[1] - fromComponents[1]) * f
        let b = fromComponents[2] + (toComponents[2] - fromComponents[2]) * f
        let a = fromComponents[3] + (toComponents[3] - fromComponents[3]) * f

        return Color(red: r, green: g, blue: b, opacity: a)
    }
}
