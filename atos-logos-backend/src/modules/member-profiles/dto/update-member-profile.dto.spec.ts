/**
 * Validation tests for UpdateMemberProfileDto, focused on the new
 * `consecrationDate` field added to the schema.
 */
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';

import { UpdateMemberProfileDto } from './update-member-profile.dto';

async function failureMessages<T extends object>(dto: T): Promise<string[]> {
  const errors = await validate(dto);
  return errors.flatMap((e) => Object.values(e.constraints ?? {}));
}

describe('UpdateMemberProfileDto — consecrationDate', () => {
  it('should accept a valid ISO date string for consecrationDate', async () => {
    // Given a partial update that includes consecrationDate
    const dto = plainToInstance(UpdateMemberProfileDto, {
      consecrationDate: '2024-06-15',
    });
    // When validated — Then no errors are reported
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should accept undefined consecrationDate because every field is optional', async () => {
    const dto = plainToInstance(UpdateMemberProfileDto, {});
    expect(await validate(dto)).toHaveLength(0);
  });

  it('should reject a malformed consecrationDate string', async () => {
    const dto = plainToInstance(UpdateMemberProfileDto, {
      consecrationDate: 'definitely-not-a-date',
    });
    expect(await failureMessages(dto)).toEqual(
      expect.arrayContaining([expect.stringContaining('consecrationDate')]),
    );
  });

  it('should reject a non-string consecrationDate', async () => {
    const dto = plainToInstance(UpdateMemberProfileDto, {
      consecrationDate: { year: 2024 },
    });
    expect((await failureMessages(dto)).length).toBeGreaterThan(0);
  });
});
