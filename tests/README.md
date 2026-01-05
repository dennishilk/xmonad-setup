# Tests

## Bats

Run the Bats suite from the repo root:

```sh
bats tests/install.bats
```

The tests stub `sudo` in `PATH` to avoid privilege escalation and validate the
`DRY-RUN` behavior of `install.sh`.
