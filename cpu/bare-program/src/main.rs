#![no_std]
#![no_main]

extern crate panic_halt;

use ulx3s_hal;
use riscv_rt::entry;

mod print;
mod timer;

use timer::Timer;

const SYSTEM_CLOCK_FREQUENCY: u32 = 50_000_000;

#[entry]
fn main() -> ! {
    let peripherals = unsafe { ulx3s_hal::Peripherals::steal() };

    print::print_hardware::set_hardware(peripherals.uart);
    let mut timer = Timer::new(peripherals.timer0);

    loop {
        print!("Hello LiteX SoC\r\n");
        msleep(&mut timer, 500);
    }
}

fn msleep(timer: &mut Timer, ms: u32) {
    timer.disable();

    timer.reload(0);
    timer.load(SYSTEM_CLOCK_FREQUENCY / 1_000 * ms);

    timer.enable();

    while timer.value() > 0 {}
}
