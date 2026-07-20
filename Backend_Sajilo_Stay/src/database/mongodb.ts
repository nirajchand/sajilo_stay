import mongoose from 'mongoose';
import dns from 'dns';
import { env } from '../config/env.js';

// Ensure SRV lookups succeed in restrictive DNS environments by using public resolvers.
dns.setServers(['1.1.1.1', '8.8.8.8']);

function buildMongoUriWithDbName(uri: string, dbName: string): string {
	const parsed = new URL(uri);
	parsed.pathname = `/${dbName}`;
	return parsed.toString();
}


export async function connectToDatabase(): Promise<void> {
	if (!env.mongoUri) {
		throw new Error('MONGODB_URI is not defined in project .env');
	}

	try {
		const mongoUriWithDbName = buildMongoUriWithDbName(env.mongoUri, env.mongoDbName);
		await mongoose.connect(mongoUriWithDbName);
		const activeDbName = mongoose.connection.db?.databaseName ?? env.mongoDbName;
		console.log(`Connected to MongoDB database: ${activeDbName}`);
	} catch (err) {
		// Surface a clearer message while preserving the original error details.
		throw new Error(`Failed to connect to MongoDB Atlas: ${String(err)}`);
	}
}

export async function disconnectFromDatabase(): Promise<void> {
	await mongoose.disconnect();
}


