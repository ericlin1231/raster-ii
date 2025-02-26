package display

import chisel3._
import chisel3.util._

class Bc1Compressor extends Module {
  val io = IO(new Bundle {
    val start = Input(Bool())
    val ready = Output(Bool())
    val done = Output(Bool())
    val addr = Output(UInt(4.W))
    val data = Input(UInt(24.W))
    val block = Output(new Bc1Block)
  })

  object State extends ChiselEnum {
    val idle, read0, minmax, read1, indices = Value
  }
  import State._
  val stateReg = RegInit(idle)
  val doneReg = RegInit(false.B)
  io.ready := false.B
  io.done := doneReg

  val addrReg = Reg(UInt(4.W))
  val minColorReg = Reg(MixedVec(UInt(5.W), UInt(6.W), UInt(5.W)))
  val maxColorReg = Reg(MixedVec(UInt(5.W), UInt(6.W), UInt(5.W)))
  val indicesReg = Reg(Vec(16, UInt(2.W)))
  io.addr := addrReg
  io.block.c0 := maxColorReg(0) ## maxColorReg(1) ## maxColorReg(2)
  io.block.c1 := minColorReg(0) ## minColorReg(1) ## minColorReg(2)
  io.block.indices := indicesReg

  switch(stateReg) {
    is(idle) {
      io.ready := true.B
      when(io.start) {
        stateReg := read0
        doneReg := false.B
        addrReg := 0.U
        minColorReg := MixedVecInit(63.U, 127.U, 63.U)
        maxColorReg := MixedVecInit(0.U, 0.U, 0.U)
      }
    }
    is(read0) {
      io.addr := addrReg
      stateReg := minmax
    }
    is(minmax) {
      val colors = Wire(MixedVec(UInt(5.W), UInt(6.W), UInt(5.W)))
      colors(0) := io.data(23, 19)
      colors(1) := io.data(15, 10)
      colors(2) := io.data(7, 3)
      for (i <- 0 to 2) {
        minColorReg(i) := Mux(
          colors(i) < minColorReg(i),
          colors(i),
          minColorReg(i)
        )
        maxColorReg(i) := Mux(
          colors(i) > maxColorReg(i),
          colors(i),
          maxColorReg(i)
        )
      }

      addrReg := addrReg + 1.U
      when(addrReg === 15.U) {
        addrReg := 0.U
        stateReg := indices
      }.otherwise {
        stateReg := read0
      }
    }
    is(read1) {
      io.addr := addrReg
      stateReg := indices
    }
    is(indices) {
      val r = Wire(Vec(4, UInt(8.W)))
      val g = Wire(Vec(4, UInt(8.W)))
      val b = Wire(Vec(4, UInt(8.W)))

      r(0) := maxColorReg(0) << 3 | maxColorReg(0)(4, 2)
      g(0) := maxColorReg(1) << 2 | maxColorReg(1)(5, 4)
      b(0) := maxColorReg(2) << 3 | maxColorReg(2)(4, 2)

      r(1) := minColorReg(0) << 3 | minColorReg(0)(4, 2)
      g(1) := minColorReg(1) << 2 | minColorReg(1)(5, 4)
      b(1) := minColorReg(2) << 3 | minColorReg(2)(4, 2)

      r(2) := ((r(0) << 2) +& r(0)) + ((r(1) << 1) +& r(1)) >> 3
      g(2) := ((g(0) << 2) +& g(0)) + ((g(1) << 1) +& g(1)) >> 3
      b(2) := ((b(0) << 2) +& b(0)) + ((b(1) << 1) +& b(1)) >> 3

      r(3) := ((r(0) << 1) +& r(0)) + ((r(1) << 2) +& r(1)) >> 3
      g(3) := ((g(0) << 1) +& g(0)) + ((g(1) << 2) +& g(1)) >> 3
      b(3) := ((b(0) << 1) +& b(0)) + ((b(1) << 2) +& b(1)) >> 3

      val d = Wire(Vec(4, SInt()))
      for (i <- 0 to 3) {
        d(i) :=
          (r(i).zext - io.data(23, 16).zext).abs +
            (g(i).zext - io.data(15, 8).zext).abs +
            (b(i).zext - io.data(7, 0).zext).abs
      }

      val b0 = d(0) > d(3)
      val b1 = d(1) > d(2)
      val b2 = d(0) > d(2)
      val b3 = d(1) > d(3)
      val b4 = d(2) > d(3)

      val x0 = b1 & b2
      val x1 = b0 & b3
      val x2 = b0 & b4
      indicesReg(addrReg) := (x0 | x1) ## x2

      addrReg := addrReg + 1.U
      when(addrReg === 15.U) {
        stateReg := idle
        doneReg := true.B
      }.otherwise {
        stateReg := read1
      }
    }
  }
}
