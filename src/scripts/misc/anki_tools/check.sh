set -e

cargo clippy -- -D warnings

cargo test
