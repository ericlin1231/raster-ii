package display

import chisel3._
import chisel3.util._

class Bc1Block extends Bundle {
  val c0 = UInt(16.W)
  val c1 = UInt(16.W)
  val indices = Vec(4, Vec(4, UInt(2.W)))
}

class Bc1Decompressor extends Module {
  val io = IO(new Bundle {
    val block = Input(new Bc1Block)
    val x = Input(UInt(2.W))
    val y = Input(UInt(2.W))
    val r = Output(UInt(5.W))
    val g = Output(UInt(6.W))
    val b = Output(UInt(5.W))
  })

  val r = Wire(Vec(4, UInt(5.W)))
  val g = Wire(Vec(4, UInt(6.W)))
  val b = Wire(Vec(4, UInt(5.W)))

  r(0) := io.block.c0(15, 11)
  g(0) := io.block.c0(10, 5)
  b(0) := io.block.c0(4, 0)

  r(1) := io.block.c1(15, 11)
  g(1) := io.block.c1(10, 5)
  b(1) := io.block.c1(4, 0)

  r(2) := ((r(0) << 2) +& r(0)) + ((r(1) << 1) +& r(1)) >> 3
  g(2) := ((g(0) << 2) +& g(0)) + ((g(1) << 1) +& g(1)) >> 3
  b(2) := ((b(0) << 2) +& b(0)) + ((b(1) << 1) +& b(1)) >> 3

  r(3) := ((r(0) << 1) +& r(0)) + ((r(1) << 2) +& r(1)) >> 3
  g(3) := ((g(0) << 1) +& g(0)) + ((g(1) << 2) +& g(1)) >> 3
  b(3) := ((b(0) << 1) +& b(0)) + ((b(1) << 2) +& b(1)) >> 3

  val index = io.block.indices(io.y)(io.x)
  io.r := r(index)
  io.g := g(index)
  io.b := b(index)
}
