//
//  ParticlesView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//


import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
}

struct ParticlesView: View {
    @State private var particles: [Particle] = []

    let particleCount: Int
    let particleSize: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: particleSize * particle.scale, height: particleSize * particle.scale)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                        .animation(.easeInOut(duration: 3.0), value: particle.opacity) // Smooth fade
                        .animation(.easeIn(duration: 3.0), value: particle.y)        // Falling animation
                }
            }
            .onAppear {
                startParticleFlow(screenWidth: geo.size.width, screenHeight: geo.size.height)
            }
        }
    }

    private func startParticleFlow(screenWidth: CGFloat, screenHeight: CGFloat) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            withAnimation {
                // Move existing particles downward
                particles = particles.map { particle in
                    var newParticle = particle
                    newParticle.y += CGFloat.random(in: 50...100) // Move downward
                    newParticle.opacity -= 0.3                    // Fade out
                    return newParticle
                }
            }

            // Add new particles periodically
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    addParticles(screenWidth: screenWidth, screenHeight: screenHeight)
                }
            }
        }
    }

    private func addParticles(screenWidth: CGFloat, screenHeight: CGFloat) {
        let newParticles = (0..<particleCount / 3).map { _ in
            Particle(
                x: CGFloat.random(in: 0...screenWidth), // Random x-position
                y: CGFloat.random(in: -50...0),        // Start above the screen
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.7...1.0) // Fresh opacity
            )
        }
        particles.append(contentsOf: newParticles)

        // Remove fully invisible particles to keep memory clean
        particles = particles.filter { $0.opacity > 0 }
    }
}

#Preview {
    ParticlesView(particleCount: 50, particleSize: 4)
}
