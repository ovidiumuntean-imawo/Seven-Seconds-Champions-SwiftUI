struct RotatingBackground: View {
        @State private var rotation: Double = 0
        
        var body: some View {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .rotationEffect(.degrees(rotation))
                    .blur(radius: 10) // Adaugă efectul de blur
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 10)
                                .repeatForever(autoreverses: false)
                        ) {
                            rotation += 360
                        }
                    }
                    .zIndex(-1) // Asigură-te că fundalul este în spate
            }
            .edgesIgnoringSafeArea(.all) // Se extinde pe întreaga zonă sigură
        }
    }