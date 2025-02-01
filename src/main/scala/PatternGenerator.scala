import chisel3._
import chisel3.util._

class PatternGenerator(width: Int, height: Int) extends Module {
  val io = IO(new Bundle {
    val addr = Output(UInt(log2Up(width * height).W))
    val data = Output(UInt(8.W))
  })

  val addrReg = RegInit(0.U(log2Up(width * height).W))
  val (rReg, rCntReg) = (RegInit(0.U(4.W)), RegInit(0.U(log2Up(40).W)))
  val (gReg, gCntReg) = (RegInit(0.U(4.W)), RegInit(0.U(log2Up(30).W)))
  addrReg := addrReg + 1.U
  rCntReg := rCntReg + 1.U
  when(addrReg === (width * height - 1).U) {
    addrReg := 0.U
  }
  when(rCntReg === 39.U) {
    rReg := rReg + 1.U
    rCntReg := 0.U
    when(rReg === 15.U) {
      gCntReg := gCntReg + 1.U
      when(gCntReg === 29.U) {
        gReg := gReg + 1.U
        gCntReg := 0.U
      }
    }
  }

  io.addr := addrReg
  io.data := rReg ## gReg
}
