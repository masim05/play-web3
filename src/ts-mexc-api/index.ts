import { config }     from './src/config';
import { MexcClient } from './src/client';

async function main() {
    console.log('API Key:',    config.MEXC_API_KEY);
    console.log('API Secret:', config.MEXC_API_SECRET);

    const mexcClient = new MexcClient(config);
    const client = mexcClient.getSpotClient();
    
    try {
        client.ping();

        const serverTime = client.time();
        console.log({ serverTime });

        const clientInfo = client.accountInfo();
        console.log({ clientInfo });
    } catch (error) {
        console.error('Error:', error);
    }
}

main();