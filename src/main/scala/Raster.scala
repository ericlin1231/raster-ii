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
  val de = RegNext(vgaController.io.de)
  io.vga.hsync := RegNext(vgaController.io.hsync)
  io.vga.vsync := RegNext(vgaController.io.vsync)
  io.x := RegNext(x)
  io.y := RegNext(y)
  io.de := de

  val framebuffer =
    SyncReadMem(vgaTiming.hactive * vgaTiming.vactive, Vec(3, UInt(4.W)))

  val pix = framebuffer.read(vgaTiming.hactive.U * y + x)
  io.vga.r := Mux(de, pix(0), 0.U)
  io.vga.g := Mux(de, pix(1), 0.U)
  io.vga.b := Mux(de, pix(2), 0.U)
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
