// Based on https://forums.raspberrypi.com/viewtopic.php?t=251335#p1536158

let RPI_PCIE_REG_BASE = UInt(0xfd500000)
let RPI_PCIE_REG_ECAM             = RPI_PCIE_REG_BASE + 0x0
let RPI_PCIE_REG_ID               = RPI_PCIE_REG_BASE + 0x043c
let RPI_PCIE_REG_MEM_PCI_LO       = RPI_PCIE_REG_BASE + 0x400c
let RPI_PCIE_REG_MEM_PCI_HI       = RPI_PCIE_REG_BASE + 0x4010
let RPI_PCIE_REG_STATUS           = RPI_PCIE_REG_BASE + 0x4068
let RPI_PCIE_REG_REV              = RPI_PCIE_REG_BASE + 0x406c
let RPI_PCIE_REG_MEM_CPU_LO       = RPI_PCIE_REG_BASE + 0x4070
let RPI_PCIE_REG_MEM_CPU_HI_START = RPI_PCIE_REG_BASE + 0x4080
let RPI_PCIE_REG_MEM_CPU_HI_END   = RPI_PCIE_REG_BASE + 0x4084
let RPI_PCIE_REG_DEBUG            = RPI_PCIE_REG_BASE + 0x4204
let RPI_PCIE_REG_INTMASK          = RPI_PCIE_REG_BASE + 0x4310
let RPI_PCIE_REG_INTCLR           = RPI_PCIE_REG_BASE + 0x4314
let RPI_PCIE_REG_CFG_DATA         = RPI_PCIE_REG_BASE + 0x8000
let RPI_PCIE_REG_CFG_INDEX        = RPI_PCIE_REG_BASE + 0x9000
let RPI_PCIE_REG_INIT             = RPI_PCIE_REG_BASE + 0x9210

func usleep(_ duration: UInt32) {
  SystemTimer.sleep(microseconds: duration)
}

enum PCIe {
  static func setup() -> Bool {
    // Reset controller.
    var ini = MMIO.read(RPI_PCIE_REG_INIT)
    ini |= 0x3
    MMIO.write(RPI_PCIE_REG_INIT, ini)
    usleep(1000)

    ini = MMIO.read(RPI_PCIE_REG_INIT)
    ini &= ~0x2
    MMIO.write(RPI_PCIE_REG_INIT, ini)

    let rev = MMIO.read(RPI_PCIE_REG_REV)
    UART.write("Revision: ")
    UART.writeln(hex: rev)

    // Clear and mask interrupts.
    MMIO.write(RPI_PCIE_REG_INTCLR, 0xffff_ffff)
    MMIO.write(RPI_PCIE_REG_INTMASK, 0xffff_ffff)

    // Take controller out of reset.
    ini = MMIO.read(RPI_PCIE_REG_INIT)
    ini &= ~0x1
    MMIO.write(RPI_PCIE_REG_INIT, ini)

    // Wait for link up (bit 0 in status)
    UART.writeln("Waiting for PCIe link up...")

    // Wait for link to become active.
    var status = MMIO.read(RPI_PCIE_REG_STATUS)
    for _ in 0..<100 {
      if (status & 0x30) == 0x30 {
        break
      }
      usleep(1000)
      status = MMIO.read(RPI_PCIE_REG_STATUS)
    }

    if (status & 0x30) != 0x30 {
      UART.writeln("PCIe link not ready...")
      return false
    }

    if (status & 0x80) != 0x80 {
      UART.writeln("PCIe is not in RC mode...")
      return false
    }

    UART.writeln("PCIe link ready")

    // Device on 0:0:0 should be a bridge.
    let bridge = MMIO.read(RPI_PCIE_REG_ECAM)
    UART.writeln("0:0:0")
    UART.write("Vendor ID: ")
    UART.writeln(hex: UInt16(bridge & 0xffff))
    UART.write("Device ID: ")
    UART.writeln(hex: UInt16((bridge >> 16) & 0xffff))

    // Configure secondary and subordinate device numbers.
    MMIO.write(RPI_PCIE_REG_ECAM + 0x18, 0x0110)

    // Set up the configuration space for reading from 1:0:0.
    MMIO.write(RPI_PCIE_REG_CFG_INDEX, 1 << 20)

    // Read device configuration for 1:0:0.
    // Should be the XHCI Controller.
    let device = MMIO.read(RPI_PCIE_REG_CFG_DATA)
    UART.writeln("1:0:0")
    UART.write("Vendor ID: ")
    UART.writeln(hex: UInt16(device & 0xffff))
    UART.write("Device ID: ")
    UART.writeln(hex: UInt16((device >> 16) & 0xffff))

    // ....

    return true
  }
}
