import chisel3._
import chisel3.util._

case class VgaTiming(
    hactive: Int,
    hfront: Int,
    hsync: Int,
    hback: Int,
    vactive: Int,
    vfront: Int,
    vsync: Int,
    vback: Int
)

class VgaController(timing: VgaTiming) extends Module {
  val hsyncStart = timing.hactive + timing.hfront
  val hsyncEnd = hsyncStart + timing.hsync
  val horizEnd = hsyncEnd + timing.hback

  val vsyncStart = timing.vactive + timing.vfront
  val vsyncEnd = vsyncStart + timing.vsync
  val vertiEnd = vsyncEnd + timing.vback

  val io = IO(new Bundle {
    val x = Output(UInt(log2Up(horizEnd).W))
    val y = Output(UInt(log2Up(vertiEnd).W))
    val hsync = Output(Bool())
    val vsync = Output(Bool())
    val de = Output(Bool())
  })

  val xReg = RegInit(0.U(log2Up(horizEnd).W))
  val yReg = RegInit(0.U(log2Up(vertiEnd).W))
  xReg := xReg + 1.U
  when(xReg === (horizEnd - 1).U) {
    xReg := 0.U
    yReg := yReg + 1.U
    when(yReg === (vertiEnd - 1).U) {
      yReg := 0.U
    }
  }
  io.x := xReg
  io.y := yReg

  io.hsync := ~(hsyncStart.U <= xReg && xReg < hsyncEnd.U)
  io.vsync := ~(vsyncStart.U <= yReg && yReg < vsyncEnd.U)
  io.de := xReg < timing.hactive.U && yReg < timing.vactive.U
}
