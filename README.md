# play-web3
## Installation
Create virtual environment:
```bash
python3 -m venv .venv
```
Install dependencies:
```bash
pip install -r requirements.txt
```

## How to run
```bash
WALLET_ADDRESS=<wallet address starting with 0x> RPC_URL=<rpc server url> python src/main.py
```
RPC server url may be taken at [chainlist](https://chainlist.org/?search=line).

## Credits
 - [Web3.0 на Python, часть 1: основы](https://habr.com/ru/articles/674204/) (Russian)