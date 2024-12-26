import chisel3._
import chisel3.util.Counter
import circt.stage.ChiselStage

class Raster extends Module {
  val io = IO(new Bundle {
    val led = Output(Bool())
  })

  val led = RegInit(true.B)
  val (_, counterWrap) = Counter(true.B, 12_500_000)
  when(counterWrap) {
    led := ~led
  }

  io.led := led
}

object Raster extends App {
  ChiselStage.emitSystemVerilogFile(
    new Raster,
    args = Array("--target-dir", "generated"),
    firtoolOpts = Array("-disable-all-randomization", "-strip-debug-info")
  )
}
