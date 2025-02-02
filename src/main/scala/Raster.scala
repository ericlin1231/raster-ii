import chisel3._
import circt.stage.ChiselStage
import display._

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
  val framebuffer = SyncReadMem(width * height, UInt(8.W))

  val displayController = Module(new DisplayController(videoTiming))
  displayController.io.rdData := framebuffer.read(displayController.io.rdAddr)
  io.r := RegNext(displayController.io.r)
  io.g := RegNext(displayController.io.g)
  io.b := RegNext(displayController.io.b)
  io.ctrl := RegNext(displayController.io.ctrl)

  val patternGenerator = Module(new PatternGenerator(width, height))
  framebuffer.write(patternGenerator.io.addr, patternGenerator.io.data)
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
