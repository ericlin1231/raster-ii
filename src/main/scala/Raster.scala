import chisel3._
import circt.stage.ChiselStage
import display._
import chisel3.util.experimental.loadMemoryFromFile

class Raster extends Module {
  val io = IO(new Bundle {
    val r = Output(UInt(8.W))
    val g = Output(UInt(8.W))
    val b = Output(UInt(8.W))
    val ctrl = Output(new VideoCtrlSignals)
  })

  val videoTiming = new VideoTiming(
    hactive = 640,
    hfront = 16,
    hsync = 96,
    hback = 48,
    vactive = 480,
    vfront = 10,
    vsync = 2,
    vback = 33
  )
  val (width, height) = (videoTiming.hactive, videoTiming.vactive)
  val framebuffer = SyncReadMem(width * height, UInt(12.W))
  loadMemoryFromFile(framebuffer, System.getProperty("user.dir") + "/assets/image.hex")

  val displayController = Module(new DisplayController(videoTiming))
  displayController.io.rdData := framebuffer.read(displayController.io.rdAddr)
  io.r := displayController.io.r
  io.g := displayController.io.g
  io.b := displayController.io.b
  io.ctrl := displayController.io.ctrl
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
