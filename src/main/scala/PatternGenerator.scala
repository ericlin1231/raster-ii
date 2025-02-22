import chisel3._
import chisel3.util._
import display.Bc1Block

class PatternGenerator(width: Int, height: Int) extends Module {
  val io = IO(new Bundle {
    val addr = Output(UInt(log2Up((width / 4) * (height / 4)).W))
    val data = Output(new Bc1Block)
  })

  val bc1Block = Wire(new Bc1Block)
  bc1Block.c0 := "hFFFF".U
  bc1Block.c1 := "hFFFF".U
  for (y <- 0 to 3) {
    for (x <- 0 to 3) {
      bc1Block.indices(y)(x) := 0.U
    }
  }

  val addrReg = RegInit(0.U(log2Up((width / 4) * (height / 4)).W))
  addrReg := addrReg + 1.U
  when(addrReg === ((width / 4) * (height / 4) - 1).U) {
    addrReg := 0.U
  }
  io.addr := addrReg
  io.data := bc1Block
}
