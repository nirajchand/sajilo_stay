import { app } from './app.js';
import { connectToDatabase, disconnectFromDatabase } from './database/mongodb.js';
import { env } from './config/env.js';

let server: ReturnType<typeof app.listen> | undefined;

async function startServer(): Promise<void> {
  try {
    await connectToDatabase();

    server = app.listen(env.port, () => {
      console.log(`Server running on port ${env.port}`);
    });
    server
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

async function shutdown(signal: NodeJS.Signals): Promise<void> {
  console.log(`Received ${signal}. Shutting down...`);

  if (server) {
    await new Promise<void>((resolve, reject) => {
      server?.close((closeError) => {
        if (closeError) {
          reject(closeError);
          return;
        }

        resolve();
      });
    });
  }

  await disconnectFromDatabase();

  process.exit(0);
}

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});

void startServer();