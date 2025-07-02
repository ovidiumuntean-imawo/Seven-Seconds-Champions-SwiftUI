class ButtonImage {
    
    static let shared = ButtonImage()
    
    private init() {}
    
    // Alege imaginea în funcție de timpul rămas și dacă este apăsat
    func getButtonImageFull(for timeLeft: Int, isPressed: Bool) -> String {
        let imagePrefix = isPressed ? "button_pressed_" : "button_normal_"
        
        switch timeLeft {
        case 6..<7:
            return imagePrefix + "1"
        case 5..<6:
            return imagePrefix + "2"
        case 4..<5:
            return imagePrefix + "3"
        case 3..<4:
            return imagePrefix + "4"
        case ..<3:
            return imagePrefix + "5"
        default:
            return isPressed ? "button_pressed" : "button_normal"
        }
    }
    
    // Alege imaginea în funcție de timpul rămas și dacă este apăsat
    func getButtonImage(for timeLeft: Int, isPressed: Bool) -> String {
        let imagePrefix = isPressed ? "button_pressed_" : "button_normal_"
        
        switch timeLeft {
        case 5..<7:
            return imagePrefix + "0"
        case 3..<5:
            return imagePrefix + "1"
        case ..<3:
            return imagePrefix + "2"
        default:
            return isPressed ? "button_pressed" : "button_normal"
        }
    }
}
