import os
import sys
from web3 import Web3

rpc_url = os.environ.get('RPC_URL')
if not rpc_url:
    sys.exit('RPC_URL must be set')

wallet_address = os.environ.get('WALLET_ADDRESS') 
if not wallet_address:
    sys.exit('WALLET_ADDRESS must be set')

web3 = Web3(Web3.HTTPProvider(rpc_url))
print(f"Is connected: {web3.is_connected()}")

print(f"gas price: {web3.eth.gas_price} BNB")
print(f"current block number: {web3.eth.block_number}")
print(f"number of current chain is {web3.eth.chain_id}")

balance = web3.eth.get_balance(wallet_address)
print(f"Wallet {wallet_address}:")
print(f"balance: {balance}")

ether_balance = Web3.from_wei(balance, 'ether')
print(f"eth balance: {ether_balance}")