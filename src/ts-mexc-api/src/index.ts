import { config }     from './config';
import { MexcClient } from './client';

const maskString = (str: string): string => {
    return str.slice(0, 4) + '.'.repeat(str.length - 4);
};

export async function main() {
    console.log('API Key:',    maskString(config.MEXC_API_KEY));
    console.log('API Secret:', maskString(config.MEXC_API_SECRET));

    const mexcClient = new MexcClient(config);
    const client = mexcClient.getSpotClient();
    
    try {
        client.ping();

        const serverTime = client.time();
        console.log({ serverTime });

        const clientInfo = client.accountInfo();
        console.log(clientInfo.balances);

        const allOrders = await client.allOrders('MITOUSDT', {limit: 5 });
        console.log({ allOrders });
    } catch (error) {
        console.error('Error:', error);
    }
}