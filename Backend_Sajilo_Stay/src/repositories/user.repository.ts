import { UserModel, UserDocument, IUser } from '../models/user.model.js';

export async function createUser(data: Partial<IUser>) {
  const user = new UserModel({
    ...data,
    profile_image: data.profile_image ?? '',
  });
  return user.save();
}

export async function findUserByEmail(email: string) {
  return UserModel.findOne({ email }).exec();
}

export async function findUserById(id: string) {
  return UserModel.findById(id).exec();
}

export async function setResetTokenForUser(id: string, token: string, expires: Date) {
  return UserModel.findByIdAndUpdate(id, {
    resetPasswordToken: token,
    resetPasswordExpires: expires,
    resetPasswordVerified: false,
  }).exec();
}

export async function markResetVerified(id: string) {
  return UserModel.findByIdAndUpdate(id, { resetPasswordVerified: true }).exec();
}

export async function updatePasswordAndClearReset(id: string, hashedPassword: string) {
  return UserModel.findByIdAndUpdate(id, {
    password: hashedPassword,
    resetPasswordToken: null,
    resetPasswordExpires: null,
    resetPasswordVerified: false,
  }).exec();
}

export async function clearResetToken(id: string) {
  return UserModel.findByIdAndUpdate(id, {
    resetPasswordToken: null,
    resetPasswordExpires: null,
    resetPasswordVerified: false,
  }).exec();
}
