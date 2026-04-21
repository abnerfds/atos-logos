import { Role } from '@prisma/client';

/** Shape of req.user after JWT strategy validation. */
export interface AuthenticatedUser {
  userId: string;
  email: string;
  churchId: string;
  branchId: string;
  role: Role;
}
