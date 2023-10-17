use extendr_api::prelude::*;
use std::cmp::min;

/// Calculate STARS RSI points and return to R as a vector
/// @param vals The column we are measuring change on
/// @param t_crit The critical value of a t-distribution at the desired p-value
/// @param l The cut-off length of a regime; affects sensitivity
#[extendr(use_try_from = true)]
fn rust_rodionov(vals: &[f64], t_crit: f64, l: usize) -> std::vec::Vec<f64> {
    let mut results = vec![0.; l];

    // calculate sigma^2_l
    // (average variance over each continuous overlapping l-long interval)
    let mut var_l: f64 = 0.;

    for i in 0..(vals.len() - l) {
        let mean: f64 = vals
            .iter()
            .skip(i)
            .take(l)
            .sum::<f64>()
            / (l as f64);

        let var_l_i: f64 = vals
            .iter()
            .skip(i)
            .take(l)
            .map(|v| (v - mean).powi(2)) // map each v to its square deviance from mean
            .sum::<f64>()
            / (l as f64); // take mean of deviances to get variation
        var_l += var_l_i;
    }

    var_l /= (vals.len() - l) as f64;

    // calculate diff from sigma^2_l
    // TODO: figure out how to calculate t_crit
    let diff: f64 = t_crit * ((2. * var_l) / (l as f64)).sqrt();

    ////// begin regime shift search

    // set initial regime length and boundaries
    let mut regime_length: usize = l;
    let mut regime_mean: f64 = vals.iter().take(l).sum::<f64>() / l as f64;
    let mut rsi: f64;
    let n: usize = vals.len();

    for i in l..n {
        if vals[i] < (regime_mean - diff) {
            rsi = calculate_rsi(
                &vals[i..min(i + l, n)],
                &(regime_mean - diff),
                true,
                &(l as f64),
                &var_l,
            )
        } else if vals[i] > (regime_mean + diff) {
            rsi = calculate_rsi(
                &vals[i..min(i + l, n)],
                &(regime_mean + diff),
                false,
                &(l as f64),
                &var_l,
            )
        } else {
            rsi = 0.;
        }

        if rsi > 0. {
            // regime boundary found; start new regime
            results.push(rsi);
            regime_length = 1;
            regime_mean = vals.iter().skip(i).take(l).sum::<f64>() / l as f64;
        } else {
            // regime test failed; add value to current regime
            results.push(0.);
            if regime_length > l {
                regime_mean = vals.iter().skip(i - l + 1).take(l).sum::<f64>() / l as f64;
            }
            regime_length += 1;
        }
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
            break;
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
