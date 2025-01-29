import chisel3._
import chisel3.util._
import _root_.circt.stage.ChiselStage

class Vga extends Bundle {
  val r = UInt(4.W)
  val g = UInt(4.W)
  val b = UInt(4.W)
  val hsync = Bool()
  val vsync = Bool()
}

class Raster extends Module {
  val io = IO(new Bundle {
    val vga = Output(new Vga)
    val x = Output(UInt())
    val y = Output(UInt())
    val de = Output(Bool())
  })

  val vgaTiming = new VgaTiming(
    hactive = 640,
    hfront = 16,
    hsync = 96,
    hback = 48,
    vactive = 480,
    vfront = 10,
    vsync = 2,
    vback = 33
  )
  val vgaController = Module(new VgaController(vgaTiming))
  val x = vgaController.io.x
  val y = vgaController.io.y
  val de = vgaController.io.de
  io.vga.hsync := vgaController.io.hsync
  io.vga.vsync := vgaController.io.vsync
  io.x := x
  io.y := y
  io.de := de

  val rCntReg = RegInit(0.U(log2Up(40).W))
  val rReg = RegInit(0.U(4.W))
  val gCntReg = RegInit(0.U(log2Up(30).W))
  val gReg = RegInit(0.U(4.W))
  when(de) {
    rCntReg := rCntReg + 1.U
    when(rCntReg === 39.U) {
      rCntReg := 0.U
      rReg := rReg + 1.U
    }

    when(x === (vgaTiming.hactive - 1).U) {
      gCntReg := gCntReg + 1.U
      when(gCntReg === 29.U) {
        gCntReg := 0.U
        gReg := gReg + 1.U
      }
    }
  }
  io.vga.r := Mux(de, rReg, 0.U)
  io.vga.g := Mux(de, gReg, 0.U)
  io.vga.b := 0.U
}

object Raster extends App {
  ChiselStage.emitSystemVerilogFile(
    new Raster,
    args = Array("--target-dir", "build"),
    firtoolOpts = Array(
      "--disable-all-randomization",
      "--lowering-options=disallowLocalVariables",
      "--strip-debug-info"
    )
  )
}
