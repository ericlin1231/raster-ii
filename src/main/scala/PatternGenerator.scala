import chisel3._
import chisel3.util._
import display._

class PatternGenerator(width: Int, height: Int) extends Module {
  val io = IO(new Bundle {
    val addr = Output(UInt(log2Up((width / 4) * (height / 4)).W))
    val data = Output(new Bc1Block)
    val enable = Output(Bool())
  })

  object State extends ChiselEnum {
    val compute, compress, write = Value
  }
  import State._
  val stateReg = RegInit(compute)
  val xReg = RegInit(0.U(log2Up(width).W))
  val yReg = RegInit(0.U(log2Up(height).W))
  val addrReg = RegInit(0.U(log2Up((width / 4) * (height / 4)).W))

  val tileMemory = SyncReadMem(16, UInt(24.W))
  val bc1Compressor = Module(new Bc1Compressor)
  bc1Compressor.io.start := false.B
  bc1Compressor.io.data := tileMemory.read(bc1Compressor.io.addr)
  io.addr := addrReg
  io.data := bc1Compressor.io.block
  io.enable := false.B

  switch(stateReg) {
    is(compute) {
      val r = ((xReg << 8.U) / width.U)(7, 0)
      val g = ((yReg << 8.U) / height.U)(7, 0)
      val b = 0.U(8.W)
      tileMemory.write((yReg(1, 0) << 2) + xReg(1, 0), r ## g ## b)

      xReg := xReg + 1.U
      when(xReg(1, 0) === 3.U) {
        xReg := xReg - 3.U
        yReg := yReg + 1.U
        when(yReg(1, 0) === 3.U) {
          yReg := yReg - 3.U
          stateReg := compress
        }
      }
    }
    is(compress) {
      bc1Compressor.io.start := true.B
      when(bc1Compressor.io.ready) {
        stateReg := write
      }
    }
    is(write) {
      when(bc1Compressor.io.done) {
        io.enable := true.B

        xReg := xReg + 4.U
        when(xReg === (width - 4).U) {
          xReg := 0.U
          yReg := yReg + 4.U
          when(yReg === (height - 4).U) {
            yReg := 0.U
          }
        }

        addrReg := addrReg + 1.U
        when(addrReg === ((width / 4) * (height / 4) - 1).U) {
          addrReg := 0.U
        }

        stateReg := compute
      }
    }
  }
}
