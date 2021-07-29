fn main() {
    // for increment in 0..256 {
    //     let p = (increment as f64) / 256.0;
    //     let angle = p * 2.0 * std::f64::consts::PI;
    //     let discretized = (f64::sin(angle) * 256.0) as i64;
    //     println!("\tdc.w {}", discretized);
    // }

    // [-32,31]?
    for y_inc in 0..64 {
        let y = (-32 + y_inc) as f64;
        for x_inc in 0..64 {            
            let x = (-32 + x_inc) as f64;    
            if x == 0.0 && y == 0.0 {
                println!("\tdc.w 0");
            } else {
                let mut at = y.atan2(x);
                // cast from [-pi,pi] to [0,2pi]
                if at < 0.0 {
                    at = 2.0*std::f64::consts::PI + at;
                }
                let d = ((at / (2.0*std::f64::consts::PI)) * 256.0) as i64;
                println!("\tdc.w {}", d);
            }
        }
    }
}
