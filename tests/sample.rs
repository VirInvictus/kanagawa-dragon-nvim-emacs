// sample.rs --- Visual eyeball buffer for Rust
//
// Open this in `rust-ts-mode' at `treesit-font-lock-level' 4 to eyeball
// the same roles as sample.java: keywords, types, strings, function
// definitions and calls, operators, parameters, and properties.

use std::collections::HashMap;
use std::fmt;

/// A tiny tag counter demonstrating doc comments, generics, types,
/// and property access.
pub struct Tally<K> {
    counts: HashMap<K, u64>,
    rounds: u32,
}

impl<K: std::hash::Hash + Eq> Tally<K> {
    pub fn new() -> Self {
        Tally {
            counts: HashMap::new(),
            rounds: 0,
        }
    }

    pub fn bump(&mut self, key: K) -> u64 {
        self.rounds += 1;
        let count = self.counts.entry(key).or_insert(0);
        *count += 1;
        *count
    }

    fn total(&self) -> u64 {
        self.counts.values().sum()
    }
}

impl<K: std::hash::Hash + Eq> fmt::Display for Tally<K> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} hits in {} rounds", self.total(), self.rounds)
    }
}

fn main() {
    let mut tally = Tally::new();
    for tag in ["red", "green", "red", "blue", "red"] {
        // Strings, numbers, operators, and macros should all pick out.
        tally.bump(tag);
    }
    println!("{tally} over {:?}", ["red", "green", "blue"]);
}
