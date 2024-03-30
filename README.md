# play-web3
## Installation
Create virtual environment (required once):
```bash
python3 -m venv .venv
```
Activate virtual environment (required every time a new terminal opened):
```bash
source .venv/bin/activate
```
Install dependencies (required once):
```bash
pip install -r requirements.txt
```

## How to run
Connect to the chain and show some params:
```bash
RPC_URL=<rpc server url> WALLET_ADDRESS=<wallet address starting with 0x> python src/chain.py
```
RPC server url may be taken at [chainlist](https://chainlist.org/).

Show wallet balance:
```bash
RPC_URL=<rpc server url> WALLET_ADDRESS=<wallet address starting with 0x> python src/wallet.py
```

Show transaction status:
```bash
RPC_URL=<rpc server url> TXN_HASH=<transaction hash> python src/txn.py
```

## Credits
 - [Web3.0 на Python, часть 1: основы](https://habr.com/ru/articles/674204/) (Russian)