//! Sample workload for the template: a sieve of Eratosthenes.
//!
//! It exists so the tooling in the shell has something real to chew on:
//!
//!     cargo nextest run                       # unit tests
//!     bacon                                   # watch and recheck on save
//!     hyperfine 'cargo run --release -- 5000000'
//!     cargo flamegraph -- 10000000

/// Returns every prime strictly below `limit`.
fn primes_below(limit: usize) -> Vec<usize> {
    if limit < 3 {
        return Vec::new();
    }

    let mut is_composite = vec![false; limit];
    let mut primes = vec![2];

    let mut candidate = 3;
    while candidate < limit {
        if !is_composite[candidate] {
            primes.push(candidate);
            let mut multiple = candidate * candidate;
            while multiple < limit {
                is_composite[multiple] = true;
                multiple += 2 * candidate;
            }
        }
        candidate += 2;
    }

    primes
}

fn main() {
    let limit = std::env::args()
        .nth(1)
        .and_then(|arg| arg.parse().ok())
        .unwrap_or(1_000_000);

    let primes = primes_below(limit);

    match primes.last() {
        Some(largest) => println!(
            "{} primes below {limit}, largest is {largest}",
            primes.len()
        ),
        None => println!("no primes below {limit}"),
    }
}

#[cfg(test)]
mod tests {
    use super::primes_below;

    #[test]
    fn handles_empty_ranges() {
        assert!(primes_below(0).is_empty());
        assert!(primes_below(2).is_empty());
    }

    #[test]
    fn excludes_the_limit_itself() {
        assert_eq!(primes_below(3), vec![2]);
        assert_eq!(primes_below(4), vec![2, 3]);
    }

    #[test]
    fn finds_the_small_primes() {
        assert_eq!(primes_below(30), vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29]);
    }

    #[test]
    fn matches_the_known_prime_count() {
        // pi(1_000_000) = 78_498
        assert_eq!(primes_below(1_000_000).len(), 78_498);
    }
}
