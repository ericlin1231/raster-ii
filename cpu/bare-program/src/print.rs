use ulx3s_hal::Uart;

pub struct UART {
    pub registers: Option<Uart>,
}

impl UART {
    pub fn putc(&self, c: u8) {
        match self.registers.as_ref() {
            Some(reg) => unsafe {
                while reg.txfull().read().bits() != 0 {
                    ()
                }
                reg.rxtx().write(|w| w.rxtx().bits(c));
            },
            None => (),
        }
    }
}

use core::fmt::{Error, Write};
impl Write for UART {
    fn write_str(&mut self, s: &str) -> Result<(), Error> {
        for c in s.bytes() {
            self.putc(c);
        }
        Ok(())
    }
}

#[macro_use]
#[cfg(not(test))]
pub mod print_hardware {
    use crate::print::*;
    pub static mut SUPERVISOR_UART: UART = UART { registers: None };

    pub fn set_hardware(uart: Uart) {
        unsafe {
            SUPERVISOR_UART.registers = Some(uart);
        }
    }

    #[macro_export]
    macro_rules! print
    {
        ($($args:tt)+) => ({
                use core::fmt::Write;
                unsafe {
                    let _ = write!(crate::print::print_hardware::SUPERVISOR_UART, $($args)+);
                }
        });
    }
}

#[macro_export]
macro_rules! println
{
    () => ({
        print!("\r\n")
    });
    ($fmt:expr) => ({
        print!(concat!($fmt, "\r\n"))
    });
    ($fmt:expr, $($args:tt)+) => ({
        print!(concat!($fmt, "\r\n"), $($args)+)
    });
}
