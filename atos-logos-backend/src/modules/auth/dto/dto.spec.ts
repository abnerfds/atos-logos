/**
 * DTO validation + transformation tests.
 *
 * Each DTO is exercised through the same pipeline NestJS uses at the
 * controller boundary: `plainToInstance` to run `@Transform` decorators,
 * then `validate` to run `class-validator` rules.
 */
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

import { LoginDto } from './login.dto';
import { SignupAdminDto } from './signup-admin.dto';
import { SelectChurchDto } from './select-church.dto';
import { RefreshDto } from './refresh.dto';
import { UpdateProfileDto } from './update-profile.dto';

async function failureMessages<T extends object>(dto: T): Promise<string[]> {
  const errors = await validate(dto);
  return errors.flatMap((e) => Object.values(e.constraints ?? {}));
}

describe('LoginDto', () => {
  it('should accept a valid email + password', async () => {
    const dto = plainToInstance(LoginDto, {
      email: 'admin@church.com',
      password: 'password123',
    });
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should trim whitespace and lowercase the email via @Transform', async () => {
    const dto = plainToInstance(LoginDto, {
      email: '  Admin@Church.COM  ',
      password: 'password123',
    });
    expect(dto.email).toBe('admin@church.com');
  });

  it('should leave non-string email values untouched (guard against crashes)', async () => {
    const dto = plainToInstance(LoginDto, {
      email: 12345 as unknown as string,
      password: 'password123',
    });
    // No transform because the guard returns the original when typeof !== 'string'.
    expect(dto.email).toBe(12345);
  });

  it('should reject a malformed email', async () => {
    const dto = plainToInstance(LoginDto, {
      email: 'not-an-email',
      password: 'password123',
    });
    expect(await failureMessages(dto)).toEqual(
      expect.arrayContaining([expect.stringContaining('email')]),
    );
  });

  it('should reject a password shorter than 6 characters', async () => {
    const dto = plainToInstance(LoginDto, {
      email: 'admin@church.com',
      password: '12345',
    });
    expect(await failureMessages(dto)).toEqual(
      expect.arrayContaining([expect.stringContaining('6')]),
    );
  });

  it('should reject missing fields', async () => {
    const dto = plainToInstance(LoginDto, {});
    const messages = await failureMessages(dto);
    expect(messages.length).toBeGreaterThan(0);
  });
});

describe('SignupAdminDto', () => {
  const valid = {
    name: 'Pastor John',
    email: 'pastor@church.com',
    password: 'password123',
    churchName: 'Grace Church',
  };

  it('should accept a valid payload', async () => {
    const dto = plainToInstance(SignupAdminDto, valid);
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should NOT type a phone field — admins set phone later via profile edit',
      () => {
    // Type-level guarantee: TypeScript would refuse `dto.phone` access.
    // We assert at runtime that the constructed instance has no phone key.
    const dto = plainToInstance(SignupAdminDto, valid);
    expect(Object.keys(dto)).not.toContain('phone');
  });

  it('should trim and lowercase the email via @Transform', async () => {
    const dto = plainToInstance(SignupAdminDto, {
      ...valid,
      email: '  Pastor@Church.COM  ',
    });
    expect(dto.email).toBe('pastor@church.com');
  });

  it('should leave non-string email values untouched', async () => {
    const dto = plainToInstance(SignupAdminDto, {
      ...valid,
      email: null as unknown as string,
    });
    expect(dto.email).toBeNull();
  });

  it('should reject malformed email', async () => {
    const dto = plainToInstance(SignupAdminDto, {
      ...valid,
      email: 'not-an-email',
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  it('should reject password shorter than 6 characters', async () => {
    const dto = plainToInstance(SignupAdminDto, {
      ...valid,
      password: '12345',
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  it('should reject missing churchName', async () => {
    const dto = plainToInstance(SignupAdminDto, {
      name: 'John',
      email: 'pastor@church.com',
      password: 'password123',
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });
});

describe('SelectChurchDto', () => {
  it('should accept a valid selection token + UUID churchId', async () => {
    const dto = plainToInstance(SelectChurchDto, {
      selectionToken: 'some-jwt-token',
      churchId: '123e4567-e89b-12d3-a456-426614174000',
    });
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should reject a non-UUID churchId', async () => {
    const dto = plainToInstance(SelectChurchDto, {
      selectionToken: 'some-jwt-token',
      churchId: 'not-a-uuid',
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  it('should reject empty selectionToken', async () => {
    const dto = plainToInstance(SelectChurchDto, {
      selectionToken: '',
      churchId: '123e4567-e89b-12d3-a456-426614174000',
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });
});

describe('RefreshDto', () => {
  it('should accept a non-empty string', async () => {
    const dto = plainToInstance(RefreshDto, { refreshToken: 'opaque-token' });
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should reject an empty refreshToken', async () => {
    const dto = plainToInstance(RefreshDto, { refreshToken: '' });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  it('should reject a non-string refreshToken', async () => {
    const dto = plainToInstance(RefreshDto, { refreshToken: 123 });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });
});

describe('UpdateProfileDto', () => {
  it('should accept an empty object (all fields are optional)', async () => {
    const dto = plainToInstance(UpdateProfileDto, {});
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should accept a full payload', async () => {
    const dto = plainToInstance(UpdateProfileDto, {
      name: 'Ana',
      cpf: '12345678900',
      phone: '11999999999',
      email: 'ana@test.com',
      country: 'Brasil',
      state: 'SP',
      city: 'São Paulo',
      neighborhood: 'Jardins',
      street: 'Rua das Flores',
      number: '123',
      complement: 'Apto 4',
    });
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should reject a malformed email', async () => {
    const dto = plainToInstance(UpdateProfileDto, { email: 'not-an-email' });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  it('should reject a non-string name', async () => {
    const dto = plainToInstance(UpdateProfileDto, { name: 123 });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });

  // ── New identity fields (rg, sex, civilStatus, fatherName, motherName) ──

  describe('rg', () => {
    it('should accept a valid rg string', async () => {
      const dto = plainToInstance(UpdateProfileDto, { rg: '12.345.678-9' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined rg', async () => {
      const dto = plainToInstance(UpdateProfileDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string rg', async () => {
      const dto = plainToInstance(UpdateProfileDto, { rg: 1234 });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('sex', () => {
    it('should accept MALE', async () => {
      const dto = plainToInstance(UpdateProfileDto, { sex: 'MALE' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept FEMALE', async () => {
      const dto = plainToInstance(UpdateProfileDto, { sex: 'FEMALE' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined sex', async () => {
      const dto = plainToInstance(UpdateProfileDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown Sex value', async () => {
      const dto = plainToInstance(UpdateProfileDto, { sex: 'OTHER' });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('civilStatus', () => {
    it('should accept MARRIED', async () => {
      const dto = plainToInstance(UpdateProfileDto, { civilStatus: 'MARRIED' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept STABLE_UNION', async () => {
      const dto = plainToInstance(UpdateProfileDto, {
        civilStatus: 'STABLE_UNION',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined civilStatus', async () => {
      const dto = plainToInstance(UpdateProfileDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown CivilStatus value', async () => {
      const dto = plainToInstance(UpdateProfileDto, {
        civilStatus: 'COMPLICATED',
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('fatherName', () => {
    it('should accept a valid string', async () => {
      const dto = plainToInstance(UpdateProfileDto, { fatherName: 'João' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined fatherName', async () => {
      const dto = plainToInstance(UpdateProfileDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string fatherName', async () => {
      const dto = plainToInstance(UpdateProfileDto, { fatherName: 9 });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('motherName', () => {
    it('should accept a valid string', async () => {
      const dto = plainToInstance(UpdateProfileDto, { motherName: 'Ana' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined motherName', async () => {
      const dto = plainToInstance(UpdateProfileDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string motherName', async () => {
      const dto = plainToInstance(UpdateProfileDto, { motherName: false });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });
});
