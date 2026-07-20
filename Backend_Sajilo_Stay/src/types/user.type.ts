import z from 'zod';

export const UserSchema = z.object({
    fullName: z.string(),
    email: z.string().email(),
    password: z.string().min(6),
    profile_image: z.string().optional(),
    role: z.enum(['USER', 'ADMIN']).optional(),
});

export type User = z.infer<typeof UserSchema>;