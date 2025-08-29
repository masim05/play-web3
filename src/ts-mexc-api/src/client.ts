import { Spot } from 'mexc-api-sdk';

interface MexcConfig {
    MEXC_API_KEY: string;
    MEXC_API_SECRET: string;
}

export class MexcClient {
    private client: Spot;

    constructor(config: MexcConfig) {
        if (!config.MEXC_API_KEY || !config.MEXC_API_SECRET) {
            throw new Error('MEXC API credentials are not configured');
        }
        this.client = new Spot(config.MEXC_API_KEY, config.MEXC_API_SECRET);
    }

    getSpotClient(): Spot {
        return this.client;
    }
}
