import { Role } from '@prisma/client';

/** Shape of the JWT token payload (what goes into jwt.sign). */
export interface JwtPayload {
  sub: string; // userId
  email: string;
  churchId: string;
  branchId: string;
  role: Role;
}

/** Shape of the short-lived selection token (multi-church login flow). */
export interface SelectionTokenPayload {
  sub: string; // userId
  email: string;
  type: 'church_selection';
}
