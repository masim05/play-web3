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
Provide `.env` file:
```bash
cp .env.example .env
```
RPC server url may be taken at [chainlist](https://chainlist.org/).

## How to run
Connect to the chain and show some params:
```bash
python src/chain.py
```

Show wallet balance:
```bash
python src/wallet.py
```

Show transaction status:
```bash
python src/txn.py
```

## Credits
 - [Web3.0 на Python, часть 1: основы](https://habr.com/ru/articles/674204/) (Russian)