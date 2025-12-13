## Rust / Cargo toolchain and shortcuts

# Compiler flags for all Rust builds
# 合并所有需要的标志
set -x RUSTFLAGS '-C link-arg=-fuse-ld=mold -C target-cpu=native --cfg tokio_unstable'

# Cargo: parallel build jobs
set -x JOBS 16

# Abbreviations for cargo workflows
abbr -a c cargo
abbr -a ct 'cargo t'
abbr -a rx 'cargo pgrx'
