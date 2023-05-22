import { z } from "zod";
import {
	groupDescriptionShape,
	groupNameShape,
	storagePathRegExp,
} from "../utils/validators";

export const groupModel = z.object({
	createdAt: z.string(),
	description: z.nullable(groupDescriptionShape),
	followers: z.array(z.string()),
	members: z.array(z.string()),
	name: groupNameShape,
	private: z.boolean(),
	icon: z.nullable(
		z.object({
			dlUrl: z.string().url(),
			location: z.string().regex(storagePathRegExp),
		}),
	),
	banner: z.nullable(
		z.object({
			dlUrl: z.string().url(),
			location: z.string().regex(storagePathRegExp),
		}),
	),
});
