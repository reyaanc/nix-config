---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---
- Check the crate you touched: `cargo check -p <crate>`, then `cargo clippy -p <crate>` and `cargo test -p <crate>`. Build the whole workspace only when the change crosses crates.
- `cargo fmt` what you changed.
- No `unwrap()` or `expect()` outside tests and genuinely unreachable cases. Propagate with `?` using the crate's existing error type; don't introduce a new error library.
- No new `unsafe`, and no `#[allow(...)]` to quiet clippy without telling me why.
- A `clone()` to get past the borrow checker is a smell. Fix the ownership first.
