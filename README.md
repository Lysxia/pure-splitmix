Pure SplitMix
=============

Purely functional splittable PRNG.

### Install with `opam`

```sh
opam pin add pure-splitmix .
```

### Tests

The unit test checks that this implementation produces the same output as
Java's `SplittableRandom`.
The expected output `ref.out` was generated using OpenJDK 8.

```sh
make test
```
