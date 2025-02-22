package display

import chisel3._
import chisel3.util._

class Bc1Compressor extends Module {
  val io = IO(new Bundle {
    val start = Input(Bool())
    val ready = Output(Bool())
    val done = Output(Bool())
    val addr = Output(UInt(log2Up(16).W))
    val data = Input(UInt(24.W))
    val block = Output(new Bc1Block)
  })

  object State extends ChiselEnum {
    val idle, read, write, done = Value
  }
  import State._
  val stateReg = RegInit(idle)
  val blockReg = Reg(new Bc1Block)
  io.ready := false.B
  io.done := false.B
  io.addr := 0.U
  io.block := blockReg

  switch(stateReg) {
    is(idle) {
      io.ready := true.B
      when(io.start) {
        stateReg := read
      }
    }
    is(read) {
      io.addr := 0.U
      stateReg := write
    }
    is(write) {
      val r = io.data(23, 16)
      val g = io.data(15, 8)
      val b = io.data(7, 0)
      blockReg.c0 := r(7, 3) ## g(7, 2) ## b(7, 3)
      blockReg.c1 := r(7, 3) ## g(7, 3) ## b(7, 3)
      for (y <- 0 to 3) {
        for (x <- 0 to 3) {
          blockReg.indices(4 * y + x) := 0.U
        }
      }
      stateReg := done
    }
    is(done) {
      io.ready := true.B
      io.done := true.B
      when(io.start) {
        stateReg := read
      }
    }
  }
}
