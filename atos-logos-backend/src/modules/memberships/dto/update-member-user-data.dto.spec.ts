/**
 * Validation tests for UpdateMemberUserDataDto, focused on the new
 * identity fields (rg, sex, civilStatus, fatherName, motherName).
 * Mirrors the pattern used in `src/modules/auth/dto/dto.spec.ts`.
 */
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

import { UpdateMemberUserDataDto } from './update-member-user-data.dto';

async function failureMessages<T extends object>(dto: T): Promise<string[]> {
  const errors = await validate(dto);
  return errors.flatMap((e) => Object.values(e.constraints ?? {}));
}

describe('UpdateMemberUserDataDto — new identity fields', () => {
  it('should accept an empty object since every field is optional', async () => {
    const dto = plainToInstance(UpdateMemberUserDataDto, {});
    expect(await validate(dto)).toHaveLength(0);
  });

  describe('rg', () => {
    it('should accept a valid rg string', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { rg: '12.345.678-9' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined rg', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string rg', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { rg: 1234 });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('sex', () => {
    it('should accept MALE', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { sex: 'MALE' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept FEMALE', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { sex: 'FEMALE' });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined sex', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown Sex value', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { sex: 'NONE' });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('civilStatus', () => {
    it('should accept SINGLE', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {
        civilStatus: 'SINGLE',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept WIDOWED', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {
        civilStatus: 'WIDOWED',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined civilStatus', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject an unknown CivilStatus value', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {
        civilStatus: 'PARTNERED',
      });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('fatherName', () => {
    it('should accept a valid string', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {
        fatherName: 'José',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined fatherName', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string fatherName', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { fatherName: 42 });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });

  describe('motherName', () => {
    it('should accept a valid string', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {
        motherName: 'Maria',
      });
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should accept undefined motherName', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, {});
      expect(await validate(dto)).toHaveLength(0);
    });

    it('should reject a non-string motherName', async () => {
      const dto = plainToInstance(UpdateMemberUserDataDto, { motherName: [] });
      expect((await failureMessages(dto)).length).toBeGreaterThan(0);
    });
  });
});
