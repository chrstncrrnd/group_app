import { z } from 'zod';
import { storagePathRegExp } from '../utils/validators';

export const postModel = z.object({
  createdAt: z.string(),
  creatorId: z.string(),
  dlUrl: z.string().url(),
  groupId: z.string(),
  pageId: z.string(),
  storageLocation: z.string().regex(storagePathRegExp),
  caption: z.string().nullable(),
});
