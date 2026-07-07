import fs from 'node:fs';
import path from 'node:path';
import multer from 'multer';

const uploadDir = path.join(process.cwd(), 'uploads', 'hotels');

fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_request, _file, callback) => {
    callback(null, uploadDir);
  },
  filename: (_request, file, callback) => {
    const fileExtension = path.extname(file.originalname);
    const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}${fileExtension}`;
    callback(null, uniqueName);
  },
});

export const hotelUpload = multer({
  storage,
  limits: {
    fileSize: 5 * 1024 * 1024,
  },
}).fields([
  { name: 'gallery', maxCount: 5 },
  { name: 'roomImages', maxCount: 5 },
]);