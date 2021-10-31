Pure SplitMix
=============

Purely functional splittable PRNG.

- 100% OCaml.
- No dependencies.

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

### See also

- [`splittable-random`](https://github.com/janestreet/splittable_random)
- [`pringo`](https://github.com/xavierleroy/pringo)
