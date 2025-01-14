    struct RotatingBackground: View {
        @State private var rotation: Double = 0

        var body: some View {
            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .rotationEffect(.degrees(rotation))
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 10)
                            .repeatForever(autoreverses: false)
                    ) {
                        rotation += 360
                    }
                }
                .zIndex(-1)
        }
    }