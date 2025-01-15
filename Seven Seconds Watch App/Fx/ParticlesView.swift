import SwiftUI

struct ParticlesView: View {
    @State private var particles: [Particle] = []

    let particleCount: Int
    let particleSize: CGFloat

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white)
                    .frame(width: particleSize * particle.scale, height: particleSize * particle.scale)
                    .opacity(particle.opacity)
                    .position(x: particle.x, y: particle.y)
                    .animation(.easeOut(duration: 1.5), value: particle.x)
            }
        }
        .onAppear {
            createParticles()
        }
    }

    private func createParticles() {
        particles = (0..<particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: 0...200),
                y: CGFloat.random(in: 0...200),
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: Double.random(in: 0.3...1.0)
            )
        }

        withAnimation(.easeOut(duration: 1.5).repeatForever(autoreverses: false)) {
            particles = particles.map { particle in
                var newParticle = particle
                newParticle.x += CGFloat.random(in: -50...50)
                newParticle.y += CGFloat.random(in: -50...50)
                newParticle.opacity = 0
                return newParticle
            }
        }
    }
}
