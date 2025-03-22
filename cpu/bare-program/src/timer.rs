use ulx3s_hal::Timer0;

pub struct Timer {
    registers: Timer0,
}

impl Timer {
    pub fn new(registers: Timer0) -> Self {
        Self { registers }
    }

    pub fn enable(&mut self) {
        unsafe {
            self.registers.en().write(|w| w.bits(1));
        }
    }

    pub fn disable(&mut self) {
        unsafe {
            self.registers.en().write(|w| w.bits(0));
        }
    }

    pub fn load(&mut self, value: u32) {
        unsafe {
            self.registers.load().write(|w| w.bits(value));
        }
    }

    pub fn reload(&mut self, value: u32) {
        unsafe {
            self.registers.reload().write(|w| w.bits(value));
        }
    }

    pub fn value(&mut self) -> u32 {
        unsafe {
            self.registers.update_value().write(|w| w.bits(1));
        }

        self.registers.value().read().bits()
    }
}
