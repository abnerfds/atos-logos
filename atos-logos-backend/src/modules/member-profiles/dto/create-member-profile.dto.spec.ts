/**
 * Validation tests for CreateMemberProfileDto, focused on the new
 * `consecrationDate` field added to the schema.
 */
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

import { CreateMemberProfileDto } from './create-member-profile.dto';

const validBase = {
  userId: '123e4567-e89b-42d3-a456-426614174000',
  branchId: '123e4567-e89b-42d3-a456-426614174001',
  birthDate: '1990-05-20',
  admissionDate: '2020-03-15',
};

async function failureMessages<T extends object>(dto: T): Promise<string[]> {
  const errors = await validate(dto);
  return errors.flatMap((e) => Object.values(e.constraints ?? {}));
}

describe('CreateMemberProfileDto — consecrationDate', () => {
  it('should accept a valid ISO date string for consecrationDate', async () => {
    // Given a complete payload with a well-formed consecrationDate
    const dto = plainToInstance(CreateMemberProfileDto, {
      ...validBase,
      consecrationDate: '2024-06-15',
    });
    // When validated — Then no errors are reported
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should accept undefined consecrationDate because it is optional', async () => {
    const dto = plainToInstance(CreateMemberProfileDto, validBase);
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should reject a malformed consecrationDate string', async () => {
    const dto = plainToInstance(CreateMemberProfileDto, {
      ...validBase,
      consecrationDate: 'not-a-date',
    });
    expect(await failureMessages(dto)).toEqual(
      expect.arrayContaining([expect.stringContaining('consecrationDate')]),
    );
  });

  it('should reject a non-string consecrationDate', async () => {
    const dto = plainToInstance(CreateMemberProfileDto, {
      ...validBase,
      consecrationDate: 12345,
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });
});
