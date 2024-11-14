import XCTest
@testable import Fetch_Recipie 

class ColorsTests: XCTestCase 
{
    // MARK: - Color Value Tests
    func testBackgroundColor() {
        // Given
        let expectedColor = UIColor(hex: "DCE4C9")
        
        // When
        let backgroundColor = Colors.backgroundColor
        
        // Then
        XCTAssertEqual(backgroundColor.toHex(), "DCE4C9")
        XCTAssertColorsEqual(backgroundColor, expectedColor)
    }
    
    func testTextColor() {
        // Given
        let expectedColor = UIColor(hex: "000000")
        
        // When
        let textColor = Colors.textColor
        
        // Then
        XCTAssertEqual(textColor.toHex(), "000000")
        XCTAssertColorsEqual(textColor, expectedColor)
    }
    
    func testButtonColor() {
        // Given
        let expectedColor = UIColor(hex: "E07B39")
        
        // When
        let buttonColor = Colors.buttonColor
        
        // Then
        XCTAssertEqual(buttonColor.toHex(), "E07B39")
        XCTAssertColorsEqual(buttonColor, expectedColor)
    }
    
    func testCollectionCardBackground() {
        // Given
        let expectedColor = UIColor(hex: "F5F5DC")
        
        // When
        let cardBackground = Colors.collectionCardBackground
        
        // Then
        XCTAssertEqual(cardBackground.toHex(), "F5F5DC")
        XCTAssertColorsEqual(cardBackground, expectedColor)
    }
    
    // MARK: - RGB Component Tests
    func testBackgroundColorComponents() {
        let color = Colors.backgroundColor
        let components = color.rgbComponents()
        
        XCTAssertEqual(components.red, 0.863, accuracy: 0.01)
        XCTAssertEqual(components.green, 0.894, accuracy: 0.01)
        XCTAssertEqual(components.blue, 0.788, accuracy: 0.01)
        XCTAssertEqual(components.alpha, 1.0)
    }
    
    func testTextColorComponents() {
        let color = Colors.textColor
        let components = color.rgbComponents()
        
        XCTAssertEqual(components.red, 0.0, accuracy: 0.01)
        XCTAssertEqual(components.green, 0.0, accuracy: 0.01)
        XCTAssertEqual(components.blue, 0.0, accuracy: 0.01)
        XCTAssertEqual(components.alpha, 1.0)
    }
}

// MARK: - Helper Extensions
extension UIColor {
    func toHex() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(
            format: "%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
    
    func rgbComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}

// MARK: - Custom Assert Function
func XCTAssertColorsEqual(
    _ color1: UIColor,
    _ color2: UIColor,
    accuracy: CGFloat = 0.01,
    file: StaticString = #file,
    line: UInt = #line
) {
    let components1 = color1.rgbComponents()
    let components2 = color2.rgbComponents()
    
    XCTAssertEqual(components1.red, components2.red, accuracy: accuracy,
                   "Red components don't match", file: file, line: line)
    XCTAssertEqual(components1.green, components2.green, accuracy: accuracy,
                   "Green components don't match", file: file, line: line)
    XCTAssertEqual(components1.blue, components2.blue, accuracy: accuracy,
                   "Blue components don't match", file: file, line: line)
    XCTAssertEqual(components1.alpha, components2.alpha, accuracy: accuracy,
                   "Alpha components don't match", file: file, line: line)
}

// MARK: - Additional Test Cases
extension ColorsTests {
    func testColorAccessibility() {
        // Test contrast ratios for text readability
        let backgroundColor = Colors.backgroundColor
        let textColor = Colors.textColor
        
        XCTAssertTrue(hasGoodContrast(backgroundColor, textColor))
    }
    
    func testColorConsistency() {
        // Test that colors remain consistent across multiple accesses
        let firstAccess = Colors.backgroundColor
        let secondAccess = Colors.backgroundColor
        
        XCTAssertColorsEqual(firstAccess, secondAccess)
    }
    
    private func hasGoodContrast(_ background: UIColor, _ foreground: UIColor) -> Bool {
        // Simplified WCAG contrast ratio calculation
        let bg = background.rgbComponents()
        let fg = foreground.rgbComponents()
        
        let bgLuminance = calculateLuminance(bg.red, bg.green, bg.blue)
        let fgLuminance = calculateLuminance(fg.red, fg.green, fg.blue)
        
        let ratio = (max(bgLuminance, fgLuminance) + 0.05) /
                   (min(bgLuminance, fgLuminance) + 0.05)
        
        return ratio >= 4.5 // WCAG AA standard for normal text
    }
    
    private func calculateLuminance(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> CGFloat {
        let r = red <= 0.03928 ? red/12.92 : pow((red + 0.055)/1.055, 2.4)
        let g = green <= 0.03928 ? green/12.92 : pow((green + 0.055)/1.055, 2.4)
        let b = blue <= 0.03928 ? blue/12.92 : pow((blue + 0.055)/1.055, 2.4)
        
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}
