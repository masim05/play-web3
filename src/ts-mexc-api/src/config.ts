import dotenv from 'dotenv';
import { z } from 'zod';

// Load .env file
dotenv.config();

// Define config schema
const configSchema = z.object({
  MEXC_API_KEY:    z.string(),
  MEXC_API_SECRET: z.string(),
  NODE_ENV:        z.enum(['development', 'production', 'test']).default('development'),
});

// Validate and export config
// TODO: throw on runtime, not on export
export const config = configSchema.parse({
  MEXC_API_KEY:    process.env.MEXC_API_KEY,
  MEXC_API_SECRET: process.env.MEXC_API_SECRET,
  NODE_ENV:        process.env.NODE_ENV,
});