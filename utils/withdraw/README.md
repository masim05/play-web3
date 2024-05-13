## Auto withdraw script
This is a super naive script which withdraws and re-delegates your commission
and rewards. You can skip this routine and jump in only in case it fails -
you'll get a telegram notofication about that. Also logs are kept in
`$HOME/withdraw.log`.

The script does pretty much the same as [auto-withdraw-delegate](https://github.com/Pretid/galactica_helpers/tree/main/auto-withdraw-delegate)
by [@Pretid](https://github.com/Pretid) (without installer though), however
reusable for different networks and keeps your host machine a bit more secure.

# Installation and setup
Download the script, review it:
```bash
curl -o withdraw.sh https://raw.githubusercontent.com/masim05/play-web3/main/utils/withdraw/withdraw.sh
```
Create a proper `.env` file in the same directory, check pre-filled examples for
[Galactica](https://github.com/masim05/play-web3/blob/main/utils/withdraw/.env.galactica.example) and
[Zero-gravity](https://github.com/masim05/play-web3/blob/main/utils/withdraw/.env.0g.example).
Add a daily job to cron:
```bash
cron_job="01 01 * * * ENV_FILE=`pwd`/.env bash `pwd`/withdraw.sh >> $HOME/withdraw.log 2>&1"
(crontab -l ; echo "$cron_job") | crontab -
```
