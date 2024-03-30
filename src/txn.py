import os
import sys
from dotenv import load_dotenv
from web3 import Web3
import yaml

load_dotenv()

rpc_url = os.environ.get('RPC_URL')
if not rpc_url:
    sys.exit('RPC_URL must be set')

txn_hash = os.environ.get('TXN_HASH')
if not txn_hash:
    sys.exit('TXN_HASH must be set')

web3 = Web3(Web3.HTTPProvider(rpc_url))
print(f"Is connected: {web3.is_connected()}")

txn_receipt = web3.eth.get_transaction_receipt(txn_hash)
print(yaml.dump(txn_receipt, allow_unicode=True, default_flow_style=False))