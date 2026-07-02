import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import dns from 'dns';

// Required: same public DNS fix as mongodb.ts to resolve Atlas SRV records
dns.setServers(['1.1.1.1', '8.8.8.8']);

dotenv.config();

const MONGODB_URI = process.env.MONGODB_URI ?? '';
const MONGODB_DB_NAME = process.env.MONGODB_DB_NAME ?? 'sajilo_stay';

const ADMIN_EMAIL = 'admin@sajilo.com';
const ADMIN_PASSWORD = 'Admin@123';
const ADMIN_NAME = 'Sajilo Admin';

async function seedAdmin() {
  const uri = new URL(MONGODB_URI);
  uri.pathname = `/${MONGODB_DB_NAME}`;
  await mongoose.connect(uri.toString());
  console.log('Connected to MongoDB');

  const db = mongoose.connection.db!;
  const users = db.collection('users');

  const existing = await users.findOne({ email: ADMIN_EMAIL });
  if (existing) {
    if (existing.role === 'ADMIN') {
      console.log(`\nAdmin already exists:\n  Email:    ${ADMIN_EMAIL}\n  Password: ${ADMIN_PASSWORD}\n`);
    } else {
      await users.updateOne({ email: ADMIN_EMAIL }, { $set: { role: 'ADMIN' } });
      console.log(`\nUpgraded existing user to ADMIN:\n  Email:    ${ADMIN_EMAIL}\n  Password: ${ADMIN_PASSWORD}\n`);
    }
    await mongoose.disconnect();
    return;
  }

  const hashed = await bcrypt.hash(ADMIN_PASSWORD, 10);
  await users.insertOne({
    fullName: ADMIN_NAME,
    email: ADMIN_EMAIL,
    password: hashed,
    role: 'ADMIN',
    profile_image: '',
    resetPasswordToken: null,
    resetPasswordExpires: null,
    createdAt: new Date(),
    updatedAt: new Date(),
  });

  console.log(`\nAdmin user created successfully!\n  Email:    ${ADMIN_EMAIL}\n  Password: ${ADMIN_PASSWORD}\n`);
  await mongoose.disconnect();
}

seedAdmin().catch((err) => {
  console.error('Seed failed:', err.message);
  process.exit(1);
});
