package display

import chisel3._

class Bc1Block extends Bundle {
  val c0 = UInt(16.W)
  val c1 = UInt(16.W)
  val indices = Vec(4, Vec(4, UInt(2.W)))
}
