import { z } from 'zod';

export const usernameRegExp =
  /^(?!_)(?!.*\.$)(?!.*\.\.)[a-z0-9._]{3,28}(?<!\.)$/;
export const emailRegExp =
  /^[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(?:\.[a-zA-Z0-9]+)*$/;
export const passwordRegExp = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d).{8,}$/;

export const storagePathRegExp = /(.+\/.+)*/gm;

export const usernameShape = z
  .string()
  .regex(usernameRegExp, 'Invalid username')
  .min(3, 'Username is too short')
  .max(20, 'Username is too long');

export const emailShape = z.string().email();

export const nameShape = z
  .string()
  .max(50, 'Name is too long')
  .min(1, 'Name is too short');

export const groupNameShape = z
  .string()
  .min(3, 'Group name is too short')
  .max(20, 'Group name is too long')
  .regex(usernameRegExp);

export const groupDescriptionShape = z
  .string()
  .max(500, 'Description is too long')
  .min(1, 'Description is too short');

// A string with a limit of 1024 characters because
// you don't want people to use this string to upload blobs
export const limStr = z.string().max(4096);
