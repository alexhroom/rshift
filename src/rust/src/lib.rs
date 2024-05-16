use extendr_api::prelude::*;
use std::cmp::min;
use std::vec::Vec;

/// Calculate STARS RSI points and return to R as a vector
/// @param vals The column we are measuring change on
/// @param t_crit The critical value of a t-distribution at the desired p-value
/// @param l The cut-off length of a regime; affects sensitivity
/// @param weights The Huber weights for each data point.
#[extendr(use_try_from = true)]
fn rust_rodionov(vals: &[f64], t_crit: f64, l: usize, weights: Vec<f64>) -> Vec<f64> {
    let mut results = vec![0.; l];

    let var_l = rolling_variance(vals, l);

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
            regime_mean = vals.iter().skip(i).take(l).sum::<f64>()
                          / weights.iter().skip(i).take(l).sum::<f64>()
        } else {
            // regime test failed; add value to current regime
            results.push(0.);
            if regime_length > l {
                regime_mean = vals.iter().skip(i - l + 1).take(l).sum::<f64>()
                              / weights.iter().skip(i - l + 1).take(l).sum::<f64>()
            }
            regime_length += 1;
        }
    }
    results
}

// calculate sigma^2_l
// (average variance over each continuous overlapping l-long interval)
fn rolling_variance(vals: &[f64], l: usize) -> f64 {
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

    var_l / (vals.len() - l) as f64
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


/// Calculate STARS RSI points and return to R as a vector
/// Uses Huber weighting to handle outliers
/// @param valsgi The column we are measuring change on
/// @param t_crit The critical value of a t-distribution at the desired p-value
/// @param l The cut-off length of a regime; affects sensitivity
/// @param huber The tuning constant for Huber weighting.
#[extendr(use_try_from = true)]
fn rust_rodionov_huber(vals: &[f64], t_crit: f64, l: usize, huber: f64) -> Vec<f64> {
    // get unweighted results and regime means to calculate anomaly
    let unweighted_results = rust_rodionov(vals, t_crit, l, [1.].repeat(vals.len()));
    let regime_means = rust_regime_means(vals, &unweighted_results);

    // calculate Huber weights
    let var_l = rolling_variance(vals, l);
    let mut weights: Vec<f64> = Vec::new();
    for i in 0..vals.len() {
        weights.push(f64::min(1., huber/((vals[i] - regime_means[i])/var_l).abs()))
    }
    let weighted_vals = vals.iter().zip(&weights).map(|(x, w)| x*w).collect::<Vec<f64>>();
    rust_rodionov(&weighted_vals, t_crit, l, weights)
}


/// Calculates the mean for each regime in a regime shift analysis.
/// @param col The column we are measuring change on.
/// @param rsi The column containing RSI values.
#[extendr(use_try_from = true)]
fn rust_regime_means(col: &[f64], rsi: &[f64]) -> Vec<f64> {
    let mut means: Vec<f64> = Vec::new();
    let mut current_regime: Vec<f64> = Vec::new();
    let mut regime_mean: f64;
    let mut regime_length: usize;

    for i in 0..col.len() {
        if rsi[i] == 0. {
            // add to current regime
            current_regime.push(col[i]);
        } else {
            // new regime starts: calculate mean of last regime
            regime_length = current_regime.len();
            regime_mean = current_regime.drain(..).sum::<f64>() / regime_length as f64;
            means.append(&mut [regime_mean].repeat(regime_length));
            current_regime.push(col[i])
        }
    }
    // calculate means for final regime
    regime_length = current_regime.len();
    regime_mean = current_regime.drain(..).sum::<f64>() / regime_length as f64;
    means.append(&mut [regime_mean].repeat(regime_length));

    means
}


// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod rshift;
    fn rust_rodionov;
    fn rust_rodionov_huber;
    fn rust_regime_means;
}
