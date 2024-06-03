//
//  InteractiveViewModel.swift
//  peakmind-pt2
//
//  Created by Raj Jagirdar on 6/3/24.
//

import Foundation
//
//  InteractiveVIewModel.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 4/25/24.
//

//
//  CauseEffectPair.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import Foundation
struct CauseEffectPair {
    var cause: String
    var effect: String
}


import Foundation
import SwiftUI

// ViewModel for handling the logic and state of the Cause and Effect view
class InteractiveViewModel: ObservableObject {
    @Published var causeEffectPairs: [CauseEffectPair] = [
        CauseEffectPair(cause: "Cause", effect: "Effect"),
        CauseEffectPair(cause: "Cause", effect: "Effect"),
        CauseEffectPair(cause: "Cause", effect: "Effect")
    ]
}

//
//  GlowingBackground.swift
//  peakmind-mvp
//
//  Created by Mingwei Li on 4/22/24.
//

import SwiftUI

struct GlowingBackground: View {
    var body: some View {
        Text("Your Text Here")
            .padding()
            .background(GlowingView(color: "1E4E96", frameWidth: 150, frameHeight: 50, cornerRadius: 10))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

struct GlowingView: View {
    var color: String
    var frameWidth: CGFloat
    var frameHeight: CGFloat
    var cornerRadius: CGFloat

    var body: some View {
        ZStack {
            let baseColor = Color(hex: color) ?? Color.black// Use the base color from hex
                        
            // Inner glow
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), baseColor.opacity(1.5)]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 70
                    )
                )
                .blur(radius: 4)
            
            // Outer glow
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(baseColor.opacity(0.3), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(baseColor.opacity(0.3), lineWidth: 0.5)
                        .blur(radius: 4)
                )
        }
        .frame(width: frameWidth, height: frameHeight)
    }
}


struct GlowingBackground_Previews: PreviewProvider {
    static var previews: some View {
        GlowingBackground()
    }
}

//
//  ColorConverter.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 2/18/24.
//

import Foundation

import SwiftUI

extension Color {
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    func toHex() -> String? {
        let uic = UIColor(self)
        guard let components = uic.cgColor.components, components.count >= 3 else {
            return nil
        }
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if a != Float(1.0) {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}

