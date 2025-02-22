package display

import chisel3._
import chisel3.util._

class DisplayController(timing: VideoTiming) extends Module {
  val io = IO(new Bundle {
    val rdAddr = Output(UInt())
    val rdData = Input(new Bc1Block)
    val r = Output(UInt(8.W))
    val g = Output(UInt(8.W))
    val b = Output(UInt(8.W))
    val ctrl = Output(new VideoCtrlSignals)
  })

  val (width, height) = (timing.hactive, timing.vactive)
  val de = Wire(Bool())
  val xReg = RegInit(0.U(log2Up(width).W))
  val yReg = RegInit(0.U(2.W))
  val yAddrReg = RegInit(0.U(log2Up((width / 4) * (height / 4)).W))
  io.rdAddr := yAddrReg + (xReg >> 2)

  when(de) {
    xReg := xReg + 1.U
    when(xReg === (width - 1).U) {
      xReg := 0.U
      yReg := yReg + 1.U
      when(yReg === 3.U) {
        yReg := 0.U
        yAddrReg := yAddrReg + (width / 4).U
        when(yAddrReg === ((width / 4) * (height / 4 - 1)).U) {
          yAddrReg := 0.U
        }
      }
    }
  }

  val bc1Decompressor = Module(new Bc1Decompressor)
  bc1Decompressor.io.block := io.rdData
  bc1Decompressor.io.x := RegNext(xReg(1, 0))
  bc1Decompressor.io.y := RegNext(yReg(1, 0))

  io.r := Mux(RegNext(de), bc1Decompressor.io.r, 0.U)
  io.g := Mux(RegNext(de), bc1Decompressor.io.g, 0.U)
  io.b := Mux(RegNext(de), bc1Decompressor.io.b, 0.U)

  val videoGenerator = Module(new VideoGenerator(timing))
  de := videoGenerator.io.ctrl.de
  io.ctrl := RegNext(videoGenerator.io.ctrl)
}
