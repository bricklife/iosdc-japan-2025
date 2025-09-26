import _Volatile

enum MMIO {
  static func write(_ address: UInt, _ value: UInt32) {
    VolatileMappedRegister<UInt32>(unsafeBitPattern: address).store(value)
  }

  static func read(_ address: UInt) -> UInt32 {
    return VolatileMappedRegister<UInt32>(unsafeBitPattern: address).load()
  }
}
