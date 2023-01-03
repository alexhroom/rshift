use extendr_api::prelude::*;

/// Calculate STARS RSI points and return to R as a vector
/// @param vals The column we are measuring change on
/// @param t_crit The critical value of a t-distribution at the desired p-value
/// @param l The cut-off length of a regime; affects sensitivity
#[extendr(use_try_from = true)]
fn rust_rodionov(vals: &[f64], t_crit: f64, l: usize) -> std::vec::Vec<f64> {
    let mut results = Vec::new();

    // calculate sigma^2_l
    // (average variance over each continuous overlapping l-long interval)
    let mut var_l: f64 = 0.;

    for i in 0..(vals.len() - l) {
        let mut sum: f64 = 0.;
        for v in vals.iter().skip(i).take(l) {
            sum += v;
        }
        let mean: f64 = sum / (l as f64);
        let mut sum_l: f64 = 0.;
        for v in vals.iter().skip(i).take(l) {
            sum_l += (v - mean).powi(2)
        }
        var_l += sum_l / (l as f64)


    }
    var_l /= (vals.len() - l) as f64;

    // calculate diff from sigma^2_l
    // TODO: figure out how to calculate t_crit
    let diff: f64 = t_crit * ((2. * var_l) / (l as f64)).sqrt();


    ////// begin regime shift search
    
    // set initial regime length and boundaries
    let mut regime_length: usize = l;
    let mut regime_mean: f64 = 0.;
    for v in vals.iter().take(l) {
        regime_mean += v;
    }
    regime_mean /= l as f64;
    let mut boundary_upper: f64 = regime_mean + diff;
    let mut boundary_lower: f64 = regime_mean - diff;

    let cand_len = vals.len() - l + 1;
    let candidates = &vals[..cand_len];
    let mut rsi: f64;

    for (i, &val) in candidates.iter().enumerate() {

        if val < boundary_lower {
            rsi = calculate_rsi(&vals[i..i+l], &boundary_lower, true, &(l as f64), &var_l)
        }
        else if val > boundary_upper {
            rsi = calculate_rsi(&vals[i..i+l], &boundary_upper, false, &(l as f64), &var_l)
        }
        else {
            rsi = 0.;
        }

        if rsi > 0. {  // regime boundary found; start new regime
            results.push(rsi);
            regime_length = l;
            regime_mean = 0.;
            for v in vals.iter().skip(i).take(l) {
                regime_mean += v;
            }
            regime_mean /= l as f64;
        } else {  // regime test failed; add value to current regime
            results.push(0.);
            regime_mean = (regime_mean * (regime_length as f64)) + val;
            regime_length += 1;
            regime_mean /= regime_length as f64;
        }
        boundary_lower = regime_mean - diff;
        boundary_upper = regime_mean + diff;
    }

    results

}

fn calculate_rsi(regime: &[f64], shift_boundary: &f64, is_down: bool, l: &f64, var_l: &f64) -> f64 {
    let mut rsi: f64 = 0.;
    let mut x_i_star: f64;
    for &val in regime {
        if is_down {
            x_i_star = shift_boundary - val;
        } else {
            x_i_star = val - shift_boundary;
        }
        rsi += x_i_star / (l * var_l.sqrt());
        if rsi < 0. {
            rsi = 0.;
            break
        }
    }
    rsi
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod rshift;
    fn rust_rodionov;
}
