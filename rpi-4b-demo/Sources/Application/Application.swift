func setupPins() {
  GPIO.selectFunction(pin: 42, function: .output)
  GPIO.selectFunction(pin: 2, function: .input)
  GPIO.selectRegistor(pin: 2, registor: .pullUp)
}

func ledOn() {
  GPIO.set(pin: 42)
}

func ledOff() {
  GPIO.clear(pin: 42)
}

func isPinHigh() -> Bool {
  GPIO.level(pin: 2)
}

func delay() {
  SystemTimer.sleep(microseconds: 125_000)
}

@main
struct Application {
  static func main() {
    UART.setup()
    UART.writeln("Hello, Embedded Swift!")

    if PCIe.setup() {
      UART.writeln("PCIe setup completed!")
    }

    if let framebuffer = Video.getFramebuffer() {
      UART.write("Framebuffer address: ")
      UART.writeln(hex: framebuffer.address)
      let offsetX = (Int(framebuffer.width) - Image.swiftLogo.width) / 2
      let offsetY = (Int(framebuffer.height) - Image.swiftLogo.height) / 2
      for y in 0..<Image.swiftLogo.height {
        for x in 0..<Image.swiftLogo.width {
          framebuffer.dot(
            x: x + offsetX,
            y: y + offsetY,
            color: Image.swiftLogo.color(x: x, y: y)
          )
        }
      }
    }

    setupPins()
    while true {
      ledOn()
      delay()
      if isPinHigh() { delay() }
      ledOff()
      delay()
      if isPinHigh() { delay() }
    }
  }
}
