package display

import chisel3._
import chisel3.util._

class DisplayController(timing: VideoTiming) extends Module {
  val io = IO(new Bundle {
    val rdAddr = Output(UInt())
    val rdData = Input(UInt(12.W))
    val r = Output(UInt(8.W))
    val g = Output(UInt(8.W))
    val b = Output(UInt(8.W))
    val ctrl = Output(new VideoCtrlSignals)
  })

  val de = Wire(Bool())
  val (width, height) = (timing.hactive, timing.vactive)
  val addrReg = RegInit(0.U(log2Up(width * height).W))
  when(de) {
    addrReg := addrReg + 1.U
    when(addrReg === (width * height - 1).U) {
      addrReg := 0.U
    }
  }
  io.rdAddr := addrReg

  io.r := Mux(RegNext(de), io.rdData(3, 0) << 4, 0.U)
  io.g := Mux(RegNext(de), io.rdData(7, 4) << 4, 0.U)
  io.b := Mux(RegNext(de), io.rdData(11, 8) << 4, 0.U)

  val videoGenerator = Module(new VideoGenerator(timing))
  de := videoGenerator.io.ctrl.de
  io.ctrl := RegNext(videoGenerator.io.ctrl)
}
