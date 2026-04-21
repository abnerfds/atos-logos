/**
 * Validation tests for CreateMemberWithUserDto, focused on the new
 * identity fields (rg, sex, civilStatus, fatherName, motherName) and the
 * new MemberProfile field (consecrationDate). Mirrors the pattern used
 * in `src/modules/auth/dto/dto.spec.ts` (plainToInstance + validate).
 */
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

import { CreateMemberWithUserDto } from './create-member-with-user.dto';

const validBase = {
  name: 'Maria Silva',
  password: 'password123',
  branchId: '123e4567-e89b-12d3-a456-426614174000',
};

async function failureMessages<T extends object>(dto: T): Promise<string[]> {
  const errors = await validate(dto);
  return errors.flatMap((e) => Object.values(e.constraints ?? {}));
}

describe('CreateMemberWithUserDto — new identity fields', () => {
  describe('rg', () => {
    it('should accept a valid rg string when provided', async () => {
      // Given a payload that includes a rg
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        rg: '12.345.678-9',
      });
      // When validated
      // Then no errors are reported
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined rg because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string rg', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        rg: 12345,
      });
      expect(await failureMessages(dto)).toEqual(
        expect.arrayContaining([expect.stringContaining('rg')]),
      );
    });
  });

  describe('sex', () => {
    it('should accept MALE as a valid Sex enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        sex: 'MALE',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept FEMALE as a valid Sex enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        sex: 'FEMALE',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined sex because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown Sex enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        sex: 'OTHER',
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('civilStatus', () => {
    it('should accept SINGLE as a valid CivilStatus enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        civilStatus: 'SINGLE',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept STABLE_UNION as a valid CivilStatus enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        civilStatus: 'STABLE_UNION',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined civilStatus because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown CivilStatus enum value', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        civilStatus: 'COMPLICATED',
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('fatherName', () => {
    it('should accept a string value when provided', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        fatherName: 'João Silva',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined fatherName because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string fatherName', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        fatherName: 999,
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('motherName', () => {
    it('should accept a string value when provided', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        motherName: 'Ana Silva',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined motherName because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string motherName', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        motherName: { first: 'Ana' },
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('consecrationDate', () => {
    it('should accept a valid ISO date string', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        consecrationDate: '2024-06-15',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined consecrationDate because it is optional', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, { ...validBase });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a malformed consecrationDate string', async () => {
      const dto = plainToInstance(CreateMemberWithUserDto, {
        ...validBase,
        consecrationDate: 'not-a-date',
      });
      expect(await failureMessages(dto)).toEqual(
        expect.arrayContaining([expect.stringContaining('consecrationDate')]),
      );
    });
  });

  it('should accept a full payload with every new identity field set', async () => {
    // Given a complete payload that exercises all newly added fields
    const dto = plainToInstance(CreateMemberWithUserDto, {
      ...validBase,
      rg: '12.345.678-9',
      sex: 'FEMALE',
      civilStatus: 'MARRIED',
      fatherName: 'Carlos',
      motherName: 'Maria',
      birthDate: '1990-01-01',
      admissionDate: '2020-01-01',
      consecrationDate: '2024-06-15',
    });
    // When validated — Then the validator reports no errors
    expect(await validate(dto)).toHaveLength(0);
  });
});
