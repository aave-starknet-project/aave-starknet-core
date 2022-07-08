# Aave Starknet Core

## Installation

To enable pre-commit hooks using [pre-commit-cairo](https://github.com/franalgaba/pre-commit-cairo).

Make sure you run the following once:

```bash
./pre-commit-install.sh
```

To install dependencies:

```bash
 protostar install
```

## Building and running tests

```bash
 protostar build
```

There's no need to run a devnet to run the tests:

```bash
 protostar test ./tests/
```

## Deploying on starknet-devnet

While running (starknet-devnet)[https://github.com/Shard-Labs/starknet-devnet] with default parameters:

```bash
 # Example with inputs:
 protostar -p devnet deploy ./build/pool.json --inputs "0x69a529e27336e28702b44c7e4143f64969681133ba9c4bd4a88c0ac7326288b"
```
