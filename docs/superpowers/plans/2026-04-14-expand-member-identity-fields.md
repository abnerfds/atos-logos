# Expand Member Identity Fields — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add identity (`rg`, `sex`, `civilStatus`, `fatherName`, `motherName`) on `User` and `consecrationDate` on `MemberProfile`, wired end-to-end through Prisma → NestJS DTOs/services → Flutter models/repository/form UI.

**Architecture:** Schema extension only. All new columns are nullable; single additive Prisma migration. Two new Prisma enums (`Sex`, `CivilStatus`). DTOs in three modules (`auth`, `memberships`, `member-profiles`) gain validated optional fields. Flutter mirrors the contract with Freezed models + two Dart enums and groups the form into three visual sections (Pessoais / Filiação / Eclesiástico).

**Tech Stack:** NestJS 10, Prisma 5 (PostgreSQL), class-validator/class-transformer, Jest, Flutter 3, Freezed + json_serializable, bloc/cubit, dio, mask_text_input_formatter.

**Spec:** `docs/superpowers/specs/2026-04-14-expand-member-identity-fields-design.md`

---

## File Structure

### Backend (`atos-logos-backend/`)

- **Modify** `prisma/schema.prisma` — add `Sex`, `CivilStatus` enums; 5 new `User` columns; `consecrationDate` on `MemberProfile`.
- **Generate** `prisma/migrations/<timestamp>_add_member_identity_and_consecration/migration.sql` — Prisma handles this.
- **Modify** `src/modules/memberships/dto/create-member-with-user.dto.ts` — add 5 user + consecrationDate fields.
- **Modify** `src/modules/memberships/dto/update-member-user-data.dto.ts` — add 5 user fields.
- **Modify** `src/modules/memberships/memberships.service.ts` — pass-through in create tx + update userFields.
- **Modify** `src/modules/memberships/memberships.service.spec.ts` — cover new fields.
- **Modify** `src/modules/member-profiles/dto/create-member-profile.dto.ts` — add `consecrationDate`.
- **Modify** `src/modules/member-profiles/dto/update-member-profile.dto.ts` — add `consecrationDate`.
- **Modify** `src/modules/member-profiles/member-profiles.service.ts` — pass-through.
- **Modify** `src/modules/member-profiles/member-profiles.service.spec.ts` — cover new field.
- **Modify** `src/modules/auth/dto/update-profile.dto.ts` — add 5 identity fields (so `/auth/me` PATCH can edit them).
- **Modify** `src/modules/auth/auth.service.ts` (if it echoes fields) and its `.spec.ts` if validation tests exist.

### Mobile (`atos_logos_mobile/`)

- **Modify** `pubspec.yaml` — add `mask_text_input_formatter`.
- **Create** `lib/core/enums/sex.dart` — Dart enum mirroring Prisma `Sex`.
- **Create** `lib/core/enums/civil_status.dart` — Dart enum mirroring Prisma `CivilStatus`.
- **Modify** `lib/features/auth/domain/models/user_profile.dart` — extend `UserProfileUser` with identity fields + `UserProfileDetail` with `consecrationDate`.
- **Modify** `lib/features/members/domain/models/member_profile.dart` — extend `MemberProfileUser` + `MemberProfile` with new fields.
- **Modify** `lib/features/members/data/members_repository.dart` — extend `createMemberWithUser` and `updateMemberUserData` signatures + payloads; extend `createMemberProfile` with `consecrationDate`.
- **Modify** `lib/features/members/presentation/cubit/members_cubit.dart` — pass-through parameters.
- **Modify** `lib/features/members/presentation/pages/create_member_page.dart` — add 6 new inputs across 3 sections (plus rename 2nd section to "Filiação" and add new "Dados Eclesiásticos" fields).
- **Modify** `lib/features/members/presentation/pages/edit_member_page.dart` — same additions as create page.

---

## Preconditions (one-time setup)

- [ ] **Step 0.1: Confirm Postgres is running** — needed for Prisma migration.

Run: `docker ps | grep postgres` (or however the project boots the DB locally — check `atos-logos-backend/README.md` if unclear).

- [ ] **Step 0.2: Install backend deps if missing**

Run inside `atos-logos-backend/`:
```
npm install
```

- [ ] **Step 0.3: Install mobile deps if missing**

Run inside `atos_logos_mobile/`:
```
flutter pub get
```

---

## Task 1: Prisma Schema — Add Enums & Columns

**Files:**
- Modify: `atos-logos-backend/prisma/schema.prisma`

- [ ] **Step 1.1: Add the two new enums after `TransactionType`**

In `atos-logos-backend/prisma/schema.prisma`, append these enums to the "Enums" block (after line 32):

```prisma
enum Sex {
  MALE
  FEMALE
}

enum CivilStatus {
  SINGLE
  MARRIED
  DIVORCED
  WIDOWED
  SEPARATED
  STABLE_UNION
}
```

- [ ] **Step 1.2: Add five new columns to `model User`**

Locate `model User` (around line 80). Insert these lines immediately after `cpf String? @unique`:

```prisma
  rg              String?
  sex             Sex?
  civilStatus     CivilStatus?
  fatherName      String?
  motherName      String?
```

- [ ] **Step 1.3: Add `consecrationDate` to `model MemberProfile`**

Locate `model MemberProfile` (around line 154). Insert after `baptismDate DateTime? @db.Date`:

```prisma
  consecrationDate   DateTime? @db.Date
```

- [ ] **Step 1.4: Format the schema**

Run inside `atos-logos-backend/`:
```
npx prisma format
```

Expected: no output; file normalized.

- [ ] **Step 1.5: Commit**

```
git add atos-logos-backend/prisma/schema.prisma
git commit -m "feat(prisma): add Sex/CivilStatus enums and identity fields on User/MemberProfile"
```

---

## Task 2: Generate & Apply Prisma Migration

**Files:**
- Create: `atos-logos-backend/prisma/migrations/<timestamp>_add_member_identity_and_consecration/migration.sql`

- [ ] **Step 2.1: Run migrate dev**

Run inside `atos-logos-backend/`:
```
npx prisma migrate dev --name add_member_identity_and_consecration
```

Expected: Prisma prints `Applying migration ...` and regenerates the client. The generated SQL should contain `CREATE TYPE "Sex"`, `CREATE TYPE "CivilStatus"`, `ALTER TABLE "users" ADD COLUMN "rg" TEXT`, etc.

- [ ] **Step 2.2: Sanity-check the generated SQL**

Open `atos-logos-backend/prisma/migrations/<timestamp>_add_member_identity_and_consecration/migration.sql`. Verify:

- All `ADD COLUMN` statements are nullable (no `NOT NULL`).
- Two `CREATE TYPE` statements exist for the new enums.
- One `ALTER TABLE "member_profiles" ADD COLUMN "consecrationDate" DATE` entry exists.

- [ ] **Step 2.3: Commit**

```
git add atos-logos-backend/prisma/migrations/
git commit -m "feat(db): migration for member identity and consecration fields"
```

---

## Task 3: Extend `CreateMemberWithUserDto`

**Files:**
- Modify: `atos-logos-backend/src/modules/memberships/dto/create-member-with-user.dto.ts`

- [ ] **Step 3.1: Add imports for the new enums**

At the top, change:

```ts
import { Role } from '@prisma/client';
```

to:

```ts
import { CivilStatus, Role, Sex } from '@prisma/client';
```

- [ ] **Step 3.2: Add the identity fields under "-- User fields --"**

Insert these fields after the existing `cpf?: string;` field:

```ts
  @IsOptional()
  @IsString()
  rg?: string;

  @IsOptional()
  @IsEnum(Sex)
  sex?: Sex;

  @IsOptional()
  @IsEnum(CivilStatus)
  civilStatus?: CivilStatus;

  @IsOptional()
  @IsString()
  fatherName?: string;

  @IsOptional()
  @IsString()
  motherName?: string;
```

- [ ] **Step 3.3: Add `consecrationDate` under optional MemberProfile fields**

At the end of the class, after `admissionDate?: string;`, add:

```ts
  @IsOptional()
  @IsDateString()
  consecrationDate?: string;
```

- [ ] **Step 3.4: Type-check**

Run inside `atos-logos-backend/`:
```
npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 3.5: Commit**

```
git add atos-logos-backend/src/modules/memberships/dto/create-member-with-user.dto.ts
git commit -m "feat(dto): widen CreateMemberWithUserDto with identity and consecration fields"
```

---

## Task 4: Extend `UpdateMemberUserDataDto`

**Files:**
- Modify: `atos-logos-backend/src/modules/memberships/dto/update-member-user-data.dto.ts`

- [ ] **Step 4.1: Add Prisma enum imports**

At the top:

```ts
import { CivilStatus, Sex } from '@prisma/client';
```

Also extend the `class-validator` import line to include `IsEnum`:

```ts
import {
  IsEmail,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MinLength,
} from 'class-validator';
```

- [ ] **Step 4.2: Add identity fields**

Insert after the existing `cpf?: string;` property (before `country`):

```ts
  @IsOptional()
  @IsString()
  rg?: string;

  @IsOptional()
  @IsEnum(Sex)
  sex?: Sex;

  @IsOptional()
  @IsEnum(CivilStatus)
  civilStatus?: CivilStatus;

  @IsOptional()
  @IsString()
  fatherName?: string;

  @IsOptional()
  @IsString()
  motherName?: string;
```

- [ ] **Step 4.3: Type-check**

Run inside `atos-logos-backend/`:
```
npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 4.4: Commit**

```
git add atos-logos-backend/src/modules/memberships/dto/update-member-user-data.dto.ts
git commit -m "feat(dto): widen UpdateMemberUserDataDto with identity fields"
```

---

## Task 5: Update `MembershipsService` create + update flows

**Files:**
- Modify: `atos-logos-backend/src/modules/memberships/memberships.service.ts`

- [ ] **Step 5.1: Write failing test — create persists identity fields**

In `atos-logos-backend/src/modules/memberships/memberships.service.spec.ts`, add a new test inside the describe block that covers `createMemberWithUser` (match the existing pattern for asserting `tx.user.create` arguments):

```ts
it('persists identity fields (rg, sex, civilStatus, fatherName, motherName) on user creation', async () => {
  // Arrange: reuse the existing happy-path setup, but include the new
  // fields in the input DTO.
  const dto = {
    name: 'Jane Doe',
    password: 'secret12',
    branchId: 'branch-uuid',
    rg: 'MG-12.345.678',
    sex: 'FEMALE' as const,
    civilStatus: 'MARRIED' as const,
    fatherName: 'John Doe',
    motherName: 'Mary Doe',
  };

  // Act
  await service.createMemberWithUser(dto, { churchId: 'church-uuid' });

  // Assert: the user.create call should include the new columns.
  expect(txUserCreate).toHaveBeenCalledWith(
    expect.objectContaining({
      data: expect.objectContaining({
        rg: 'MG-12.345.678',
        sex: 'FEMALE',
        civilStatus: 'MARRIED',
        fatherName: 'John Doe',
        motherName: 'Mary Doe',
      }),
    }),
  );
});
```

Note: match the existing spec's mocking style; if the spec uses `prismaMock.user.create` instead of a local `txUserCreate`, assert on that.

- [ ] **Step 5.2: Run the test — verify it fails**

Run inside `atos-logos-backend/`:
```
npx jest src/modules/memberships/memberships.service.spec.ts -t "persists identity fields"
```

Expected: FAIL because the service doesn't forward the fields yet.

- [ ] **Step 5.3: Extend `tx.user.create` in `createMemberWithUser`**

Around line 129, change the `data` block to:

```ts
        const user = await tx.user.create({
          data: {
            name: dto.name,
            email: dto.email,
            phone: dto.phone,
            cpf: dto.cpf,
            rg: dto.rg,
            sex: dto.sex,
            civilStatus: dto.civilStatus,
            fatherName: dto.fatherName,
            motherName: dto.motherName,
            password: hashedPassword,
          },
        });
```

- [ ] **Step 5.4: Extend the `memberProfile.create` block with `consecrationDate`**

Around line 159–168, change to:

```ts
          profile = await tx.memberProfile.create({
            data: {
              userId: user.id,
              churchId,
              registrationNumber,
              birthDate: new Date(dto.birthDate!),
              admissionDate: new Date(dto.admissionDate!),
              baptismDate: dto.baptismDate ? new Date(dto.baptismDate) : null,
              consecrationDate: dto.consecrationDate
                ? new Date(dto.consecrationDate)
                : null,
            },
          });
```

- [ ] **Step 5.5: Add identity fields to `userFields` in the update flow**

Around line 255, change the `userFields` array to include the new fields:

```ts
    const userFields: Array<keyof UpdateMemberUserDataDto> = [
      'name',
      'email',
      'phone',
      'cpf',
      'rg',
      'sex',
      'civilStatus',
      'fatherName',
      'motherName',
      'country',
      'state',
      'city',
      'neighborhood',
      'street',
      'number',
      'complement',
    ];
```

The existing loop already uses `value !== undefined`, so new fields are auto-handled. However, the typed `Record<string, string>` is too narrow for enum values — widen it:

```ts
    const userData: Record<string, string | Sex | CivilStatus> = {};
```

Add the import at the top of the file if not already present:

```ts
import { CivilStatus, Sex } from '@prisma/client';
```

- [ ] **Step 5.6: Re-run the test — verify it passes**

Run inside `atos-logos-backend/`:
```
npx jest src/modules/memberships/memberships.service.spec.ts -t "persists identity fields"
```

Expected: PASS.

- [ ] **Step 5.7: Run the full memberships service suite**

Run:
```
npx jest src/modules/memberships/memberships.service.spec.ts
```

Expected: all tests PASS.

- [ ] **Step 5.8: Add a test for update flow — persists new fields**

In the same spec, add:

```ts
it('updateMemberUserData persists new identity fields', async () => {
  // Arrange: reuse the existing happy-path update setup with
  // just the new fields as input.
  const userId = 'user-uuid';
  const dto = {
    rg: 'SP-99.999.999',
    sex: 'MALE' as const,
    civilStatus: 'SINGLE' as const,
    fatherName: 'A',
    motherName: 'B',
  };

  await service.updateMemberUserData(userId, dto, { churchId: 'church-uuid' });

  expect(txUserUpdate).toHaveBeenCalledWith(
    expect.objectContaining({
      where: { id: userId },
      data: expect.objectContaining({
        rg: 'SP-99.999.999',
        sex: 'MALE',
        civilStatus: 'SINGLE',
        fatherName: 'A',
        motherName: 'B',
      }),
    }),
  );
});
```

- [ ] **Step 5.9: Run and verify PASS**

Run:
```
npx jest src/modules/memberships/memberships.service.spec.ts -t "updateMemberUserData persists new identity fields"
```

Expected: PASS.

- [ ] **Step 5.10: Commit**

```
git add atos-logos-backend/src/modules/memberships/memberships.service.ts \
        atos-logos-backend/src/modules/memberships/memberships.service.spec.ts
git commit -m "feat(memberships): forward identity and consecration fields to Prisma"
```

---

## Task 6: Extend MemberProfile DTOs

**Files:**
- Modify: `atos-logos-backend/src/modules/member-profiles/dto/create-member-profile.dto.ts`
- Modify: `atos-logos-backend/src/modules/member-profiles/dto/update-member-profile.dto.ts`

- [ ] **Step 6.1: Add `consecrationDate` to `CreateMemberProfileDto`**

Insert after `baptismDate?: string;` (line 18):

```ts
  @IsOptional()
  @IsDateString()
  consecrationDate?: string;
```

- [ ] **Step 6.2: Add `consecrationDate` to `UpdateMemberProfileDto`**

Insert after `baptismDate?: string;` (line 11):

```ts
  @IsOptional()
  @IsDateString()
  consecrationDate?: string;
```

- [ ] **Step 6.3: Type-check**

Run:
```
npx tsc --noEmit
```

Expected: no errors.

- [ ] **Step 6.4: Commit**

```
git add atos-logos-backend/src/modules/member-profiles/dto/
git commit -m "feat(dto): add consecrationDate to MemberProfile create/update DTOs"
```

---

## Task 7: Update `MemberProfilesService` to persist consecrationDate

**Files:**
- Modify: `atos-logos-backend/src/modules/member-profiles/member-profiles.service.ts`
- Modify: `atos-logos-backend/src/modules/member-profiles/member-profiles.service.spec.ts`

- [ ] **Step 7.1: Add a failing test — create persists consecrationDate**

Inspect the existing spec's happy-path for `create()` first (so the new test matches style). Then add:

```ts
it('persists consecrationDate on create', async () => {
  const dto = {
    userId: 'user-uuid',
    branchId: 'branch-uuid',
    birthDate: '1990-01-01',
    admissionDate: '2020-05-10',
    consecrationDate: '2022-09-15',
  };
  await service.create(dto, { churchId: 'church-uuid' });
  expect(prismaMock.memberProfile.create).toHaveBeenCalledWith(
    expect.objectContaining({
      data: expect.objectContaining({
        consecrationDate: new Date('2022-09-15'),
      }),
    }),
  );
});
```

Also add a mirror `update()` test:

```ts
it('persists consecrationDate on update', async () => {
  await service.update('profile-uuid', { consecrationDate: '2023-01-01' }, {
    churchId: 'church-uuid',
  });
  expect(prismaMock.memberProfile.update).toHaveBeenCalledWith(
    expect.objectContaining({
      data: expect.objectContaining({
        consecrationDate: new Date('2023-01-01'),
      }),
    }),
  );
});
```

- [ ] **Step 7.2: Run the tests — verify they fail**

Run:
```
npx jest src/modules/member-profiles/member-profiles.service.spec.ts -t "consecrationDate"
```

Expected: FAIL for both tests.

- [ ] **Step 7.3: Update `member-profiles.service.ts` `create` method**

In the `create` method, add `consecrationDate` handling next to the existing `baptismDate` handling. Typical pattern (adapt to the existing shape):

```ts
consecrationDate: dto.consecrationDate ? new Date(dto.consecrationDate) : null,
```

Add to both the `create` and `update` Prisma calls (the existing file handles these differently — follow that style).

- [ ] **Step 7.4: Run the tests — verify they pass**

Run:
```
npx jest src/modules/member-profiles/member-profiles.service.spec.ts -t "consecrationDate"
```

Expected: PASS.

- [ ] **Step 7.5: Run full MemberProfiles suite**

```
npx jest src/modules/member-profiles/
```

Expected: all tests PASS.

- [ ] **Step 7.6: Commit**

```
git add atos-logos-backend/src/modules/member-profiles/
git commit -m "feat(member-profiles): persist consecrationDate on create/update"
```

---

## Task 8: Extend `UpdateProfileDto` (auth /me endpoint)

**Files:**
- Modify: `atos-logos-backend/src/modules/auth/dto/update-profile.dto.ts`

- [ ] **Step 8.1: Update imports**

Replace the imports line with:

```ts
import { IsString, IsOptional, IsEmail, IsEnum } from 'class-validator';
import { CivilStatus, Sex } from '@prisma/client';
```

- [ ] **Step 8.2: Add the identity fields**

Insert after the existing `cpf?: string;` property (before `phone`):

```ts
  @IsOptional()
  @IsString()
  rg?: string;

  @IsOptional()
  @IsEnum(Sex)
  sex?: Sex;

  @IsOptional()
  @IsEnum(CivilStatus)
  civilStatus?: CivilStatus;

  @IsOptional()
  @IsString()
  fatherName?: string;

  @IsOptional()
  @IsString()
  motherName?: string;
```

- [ ] **Step 8.3: Check if auth service forwards these fields**

Run:
```
npx grep -n "cpf" atos-logos-backend/src/modules/auth/auth.service.ts
```

If the service explicitly whitelists fields (like memberships does with `userFields`), add the five new fields to that whitelist. If it spreads the DTO (e.g., `data: dto`), no change is needed.

- [ ] **Step 8.4: Type-check and run auth tests**

```
npx tsc --noEmit
npx jest src/modules/auth/
```

Expected: all tests PASS.

- [ ] **Step 8.5: Commit**

```
git add atos-logos-backend/src/modules/auth/
git commit -m "feat(auth): allow identity fields in /auth/me PATCH payload"
```

---

## Task 9: Run full backend suite + build

**Files:** (no file edits — verification only)

- [ ] **Step 9.1: Full jest run**

Run inside `atos-logos-backend/`:
```
npx jest
```

Expected: all green.

- [ ] **Step 9.2: Coverage check**

Per project convention (`MEMORY.md` reference `feedback_coverage_verification.md`):

```
npx jest --coverage
```

Look at the coverage summary. If any file touched in Tasks 3–8 is below 100% on the new lines, add missing unit tests until covered or document the uncovered line with an inline comment explaining why it's unreachable.

- [ ] **Step 9.3: Build**

Per project convention (`MEMORY.md` reference `feedback_verify_build.md`) — always verify the real build before declaring done:

```
npm run build
```

Expected: clean build, no TypeScript errors.

- [ ] **Step 9.4: Commit (if any new tests were added)**

```
git add atos-logos-backend/src/
git commit -m "test(backend): close coverage gaps on new identity fields"
```

(Skip if there are no changes.)

---

## Task 10: Mobile — add `mask_text_input_formatter` dependency

**Files:**
- Modify: `atos_logos_mobile/pubspec.yaml`

- [ ] **Step 10.1: Add dependency**

In `atos_logos_mobile/pubspec.yaml`, under `dependencies:` add:

```yaml
  mask_text_input_formatter: ^2.9.0
```

- [ ] **Step 10.2: Fetch deps**

Run inside `atos_logos_mobile/`:
```
flutter pub get
```

Expected: `Got dependencies!`

- [ ] **Step 10.3: Commit**

```
git add atos_logos_mobile/pubspec.yaml atos_logos_mobile/pubspec.lock
git commit -m "chore(mobile): add mask_text_input_formatter"
```

---

## Task 11: Mobile — create `Sex` and `CivilStatus` enums

**Files:**
- Create: `atos_logos_mobile/lib/core/enums/sex.dart`
- Create: `atos_logos_mobile/lib/core/enums/civil_status.dart`

- [ ] **Step 11.1: Create `sex.dart`**

Write to `atos_logos_mobile/lib/core/enums/sex.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum Sex {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
}

extension SexLabel on Sex {
  String get label {
    switch (this) {
      case Sex.male:
        return 'Masculino';
      case Sex.female:
        return 'Feminino';
    }
  }

  String get wireValue {
    switch (this) {
      case Sex.male:
        return 'MALE';
      case Sex.female:
        return 'FEMALE';
    }
  }
}
```

- [ ] **Step 11.2: Create `civil_status.dart`**

Write to `atos_logos_mobile/lib/core/enums/civil_status.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum CivilStatus {
  @JsonValue('SINGLE')
  single,
  @JsonValue('MARRIED')
  married,
  @JsonValue('DIVORCED')
  divorced,
  @JsonValue('WIDOWED')
  widowed,
  @JsonValue('SEPARATED')
  separated,
  @JsonValue('STABLE_UNION')
  stableUnion,
}

extension CivilStatusLabel on CivilStatus {
  String get label {
    switch (this) {
      case CivilStatus.single:
        return 'Solteiro(a)';
      case CivilStatus.married:
        return 'Casado(a)';
      case CivilStatus.divorced:
        return 'Divorciado(a)';
      case CivilStatus.widowed:
        return 'Viúvo(a)';
      case CivilStatus.separated:
        return 'Separado(a)';
      case CivilStatus.stableUnion:
        return 'União Estável';
    }
  }

  String get wireValue {
    switch (this) {
      case CivilStatus.single:
        return 'SINGLE';
      case CivilStatus.married:
        return 'MARRIED';
      case CivilStatus.divorced:
        return 'DIVORCED';
      case CivilStatus.widowed:
        return 'WIDOWED';
      case CivilStatus.separated:
        return 'SEPARATED';
      case CivilStatus.stableUnion:
        return 'STABLE_UNION';
    }
  }
}
```

- [ ] **Step 11.3: Commit**

```
git add atos_logos_mobile/lib/core/enums/
git commit -m "feat(mobile): add Sex and CivilStatus enums"
```

---

## Task 12: Mobile — extend `UserProfile` domain model

**Files:**
- Modify: `atos_logos_mobile/lib/features/auth/domain/models/user_profile.dart`

- [ ] **Step 12.1: Extend `UserProfileUser` with identity fields**

Replace the body of `UserProfileUser` (lines 22–37) with:

```dart
  const factory UserProfileUser({
    required String id,
    required String name,
    required String email,
    String? phone,
    String? cpf,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) = _UserProfileUser;
```

Note: we keep `sex` / `civilStatus` as `String?` in the wire model (pass-through raw enum string) and convert to the typed enum at the UI boundary. This keeps serialization trivial.

- [ ] **Step 12.2: Extend `UserProfileDetail` with `consecrationDate`**

Replace the body of `UserProfileDetail` (lines 43–50) with:

```dart
  const factory UserProfileDetail({
    String? photoUrl,
    String? admissionDate,
    String? birthDate,
    String? baptismDate,
    String? consecrationDate,
    String? registrationNumber,
  }) = _UserProfileDetail;
```

- [ ] **Step 12.3: Regenerate freezed/json_serializable files**

Run inside `atos_logos_mobile/`:
```
dart run build_runner build --delete-conflicting-outputs
```

Expected: new `.freezed.dart` and `.g.dart` files are regenerated without error.

- [ ] **Step 12.4: Flutter analyze**

```
flutter analyze lib/features/auth
```

Expected: no errors.

- [ ] **Step 12.5: Commit**

```
git add atos_logos_mobile/lib/features/auth/domain/models/user_profile.dart \
        atos_logos_mobile/lib/features/auth/domain/models/user_profile.freezed.dart \
        atos_logos_mobile/lib/features/auth/domain/models/user_profile.g.dart
git commit -m "feat(mobile): extend UserProfile domain model with identity fields"
```

---

## Task 13: Mobile — extend `MemberProfile` domain model

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/domain/models/member_profile.dart`

- [ ] **Step 13.1: Extend `MemberProfileUser`**

Replace the body (lines 8–22) with:

```dart
  const factory MemberProfileUser({
    required String id,
    required String name,
    String? email,
    String? phone,
    String? cpf,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) = _MemberProfileUser;
```

- [ ] **Step 13.2: Extend `MemberProfile` with `consecrationDate`**

Replace the body (lines 29–40) with:

```dart
  const factory MemberProfile({
    String? id,
    required String userId,
    required String churchId,
    String? registrationNumber,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
    String? photoUrl,
    MemberProfileUser? user,
  }) = _MemberProfile;
```

- [ ] **Step 13.3: Regenerate**

```
dart run build_runner build --delete-conflicting-outputs
```

Expected: no errors.

- [ ] **Step 13.4: Flutter analyze**

```
flutter analyze lib/features/members
```

Expected: no errors.

- [ ] **Step 13.5: Commit**

```
git add atos_logos_mobile/lib/features/members/domain/models/
git commit -m "feat(mobile): extend MemberProfile domain model with identity fields"
```

---

## Task 14: Mobile — extend `MembersRepository` signatures

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/data/members_repository.dart`

- [ ] **Step 14.1: Extend `createMemberWithUser`**

Locate `createMemberWithUser` (line 64) and modify the signature + payload. Replace the entire method with:

```dart
  Future<Map<String, dynamic>> createMemberWithUser({
    required String name,
    required String password,
    required String branchId,
    String? email,
    String? cpf,
    String? phone,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? role,
    String? positionId,
    String? birthDate,
    String? baptismDate,
    String? admissionDate,
    String? consecrationDate,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'password': password,
      'branchId': branchId,
      if (email != null && email.isNotEmpty) 'email': email,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (rg != null && rg.isNotEmpty) 'rg': rg,
      if (sex != null && sex.isNotEmpty) 'sex': sex,
      if (civilStatus != null && civilStatus.isNotEmpty)
        'civilStatus': civilStatus,
      if (fatherName != null && fatherName.isNotEmpty) 'fatherName': fatherName,
      if (motherName != null && motherName.isNotEmpty) 'motherName': motherName,
      if (role != null && role.isNotEmpty) 'role': role,
      if (positionId != null && positionId.isNotEmpty)
        'positionId': positionId,
      if (birthDate != null && birthDate.isNotEmpty) 'birthDate': birthDate,
      if (baptismDate != null && baptismDate.isNotEmpty)
        'baptismDate': baptismDate,
      if (admissionDate != null && admissionDate.isNotEmpty)
        'admissionDate': admissionDate,
      if (consecrationDate != null && consecrationDate.isNotEmpty)
        'consecrationDate': consecrationDate,
    };

    try {
      final response = await _dio.post<dynamic>(
        '/memberships/with-user',
        data: payload,
      );
      return (response.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] ?? 'Erro ao criar membro',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

- [ ] **Step 14.2: Extend `updateMemberUserData`**

Locate `updateMemberUserData` (line 114) and add the new parameters + payload entries. Replace the method with:

```dart
  Future<Map<String, dynamic>> updateMemberUserData({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    String? rg,
    String? sex,
    String? civilStatus,
    String? fatherName,
    String? motherName,
    String? country,
    String? state,
    String? city,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
    String? branchId,
    String? positionId,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (email != null && email.isNotEmpty) 'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (cpf != null && cpf.isNotEmpty) 'cpf': cpf,
      if (rg != null && rg.isNotEmpty) 'rg': rg,
      if (sex != null && sex.isNotEmpty) 'sex': sex,
      if (civilStatus != null && civilStatus.isNotEmpty)
        'civilStatus': civilStatus,
      if (fatherName != null && fatherName.isNotEmpty) 'fatherName': fatherName,
      if (motherName != null && motherName.isNotEmpty) 'motherName': motherName,
      if (country != null && country.isNotEmpty) 'country': country,
      if (state != null && state.isNotEmpty) 'state': state,
      if (city != null && city.isNotEmpty) 'city': city,
      if (neighborhood != null && neighborhood.isNotEmpty)
        'neighborhood': neighborhood,
      if (street != null && street.isNotEmpty) 'street': street,
      if (number != null && number.isNotEmpty) 'number': number,
      if (complement != null && complement.isNotEmpty) 'complement': complement,
      if (branchId != null && branchId.isNotEmpty) 'branchId': branchId,
      if (positionId != null && positionId.isNotEmpty) 'positionId': positionId,
    };

    try {
      final response = await _dio.patch<dynamic>(
        '/memberships/by-user/$userId/user-data',
        data: payload,
      );
      return (response.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] ??
            'Erro ao atualizar dados do membro',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

- [ ] **Step 14.3: Extend `createMemberProfile` with `consecrationDate`**

Locate `createMemberProfile` (line 188). Replace with:

```dart
  Future<MemberProfile> createMemberProfile({
    required String userId,
    required String branchId,
    required String birthDate,
    String? baptismDate,
    required String admissionDate,
    String? consecrationDate,
    String? photoUrl,
  }) async {
    try {
      final response = await _dio.post('/member-profiles', data: {
        'userId': userId,
        'branchId': branchId,
        'birthDate': birthDate,
        'admissionDate': admissionDate,
        if (baptismDate != null) 'baptismDate': baptismDate,
        if (consecrationDate != null) 'consecrationDate': consecrationDate,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });
      return MemberProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException(
        e.response?.data?['message'] ?? 'Erro ao criar perfil',
        statusCode: e.response?.statusCode,
      );
    }
  }
```

- [ ] **Step 14.4: Flutter analyze**

```
flutter analyze lib/features/members/data
```

Expected: no errors.

- [ ] **Step 14.5: Commit**

```
git add atos_logos_mobile/lib/features/members/data/members_repository.dart
git commit -m "feat(mobile): thread identity and consecration fields through MembersRepository"
```

---

## Task 15: Mobile — extend `MembersCubit` pass-through

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/presentation/cubit/members_cubit.dart`

- [ ] **Step 15.1: Locate `createMemberWithUser` in the cubit**

Open the file and find the public method that wraps the repository's `createMemberWithUser`.

- [ ] **Step 15.2: Add the new named parameters and forward them to the repository**

The shape mirrors the repository. Add these optional params to the cubit method's signature and pass them through to `_repository.createMemberWithUser(...)`:

```
String? rg,
String? sex,
String? civilStatus,
String? fatherName,
String? motherName,
String? consecrationDate,
```

- [ ] **Step 15.3: Mirror changes for any update-wrapping method**

If the cubit has a wrapper around `updateMemberUserData`, add the same 5 identity params and forward them.

- [ ] **Step 15.4: Flutter analyze**

```
flutter analyze lib/features/members/presentation/cubit
```

Expected: no errors.

- [ ] **Step 15.5: Commit**

```
git add atos_logos_mobile/lib/features/members/presentation/cubit/
git commit -m "feat(mobile): thread identity and consecration fields through MembersCubit"
```

---

## Task 16: Mobile — extend `CreateMemberPage` form

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/presentation/pages/create_member_page.dart`

- [ ] **Step 16.1: Import the new enums and mask formatter**

Add near the top (after existing imports):

```dart
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../../core/enums/sex.dart';
import '../../../../core/enums/civil_status.dart';
```

- [ ] **Step 16.2: Add controllers + state for the new fields**

In the `_CreateMemberPageState` class, next to the existing controllers, add:

```dart
  final _rgController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _consecrationDateController = TextEditingController();
  Sex? _selectedSex;
  CivilStatus? _selectedCivilStatus;
  bool _filiationExpanded = true;

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
```

Note: RG is intentionally not masked (formats vary by state).

- [ ] **Step 16.3: Dispose the new controllers**

Inside `dispose()`, add after the existing disposals:

```dart
    _rgController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _consecrationDateController.dispose();
```

- [ ] **Step 16.4: Apply the CPF mask to the existing CPF field**

On the existing CPF `TextFormField` (around line 427), add:

```dart
                                      inputFormatters: [_cpfMask],
```

- [ ] **Step 16.5: Insert new inputs in "Informacoes Pessoais" section**

Inside the `Dados Pessoais` `_AccordionSection`'s `child` (Column), after the Telefone/Data de Nascimento row, add a new row + block:

```dart
                          const SizedBox(height: 16),
                          // 2-col: RG + Sexo
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('RG'),
                                    const SizedBox(height: 6),
                                    TextFormField(
                                      controller: _rgController,
                                      decoration: _inputDecoration(
                                        hint: 'Documento de identidade',
                                      ),
                                      style: GoogleFonts.inter(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('SEXO'),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3E9EE),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: DropdownButtonFormField<Sex>(
                                        initialValue: _selectedSex,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12),
                                          hintText: 'Selecione',
                                          hintStyle: GoogleFonts.inter(
                                            color: const Color(0xFF747C81),
                                            fontSize: 14,
                                          ),
                                        ),
                                        items: Sex.values
                                            .map((s) => DropdownMenuItem(
                                                  value: s,
                                                  child: Text(s.label),
                                                ))
                                            .toList(),
                                        onChanged: (v) =>
                                            setState(() => _selectedSex = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('ESTADO CIVIL'),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3E9EE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonFormField<CivilStatus>(
                              initialValue: _selectedCivilStatus,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                hintText: 'Selecione',
                                hintStyle: GoogleFonts.inter(
                                  color: const Color(0xFF747C81),
                                  fontSize: 14,
                                ),
                              ),
                              items: CivilStatus.values
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.label),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCivilStatus = v),
                            ),
                          ),
```

- [ ] **Step 16.6: Insert a new "Filiação" accordion section**

Between the "Informacoes Pessoais" and "Dados Eclesiasticos" sections, add:

```dart
                    const SizedBox(height: 16),

                    // -- Section 2: Filiacao --
                    _AccordionSection(
                      icon: Icons.family_restroom_outlined,
                      title: 'Filiação',
                      isExpanded: _filiationExpanded,
                      onToggle: () => setState(
                        () => _filiationExpanded = !_filiationExpanded,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('NOME DO PAI'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _fatherNameController,
                            decoration:
                                _inputDecoration(hint: 'Nome completo'),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('NOME DA MÃE'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _motherNameController,
                            decoration:
                                _inputDecoration(hint: 'Nome completo'),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
```

- [ ] **Step 16.7: Add `consecrationDate` input inside "Dados Eclesiasticos"**

Inside the existing `Dados Eclesiasticos` section's Column, after the Data de Batismo/Data de Admissao row, add:

```dart
                          const SizedBox(height: 16),
                          _buildLabel('DATA DE CONSAGRAÇÃO'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _consecrationDateController,
                            readOnly: true,
                            onTap: () =>
                                _selectDate(_consecrationDateController),
                            decoration: _inputDecoration(
                              hint: 'dd/mm/aaaa',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                color: Color(0xFF747C81),
                                size: 20,
                              ),
                            ),
                            style: GoogleFonts.inter(fontSize: 14),
                          ),
```

- [ ] **Step 16.8: Forward the new values in `_onSubmit`**

Change the `createMemberWithUser(...)` call to also pass the new fields:

```dart
      await context.read<MembersCubit>().createMemberWithUser(
            name: _nameController.text.trim(),
            password: tempPassword,
            branchId: _selectedBranch!,
            email: _emailController.text.trim(),
            cpf: _cpfController.text.trim(),
            phone: _phoneController.text.trim(),
            rg: _rgController.text.trim(),
            sex: _selectedSex?.wireValue,
            civilStatus: _selectedCivilStatus?.wireValue,
            fatherName: _fatherNameController.text.trim(),
            motherName: _motherNameController.text.trim(),
            positionId: _selectedPosition,
            birthDate: _toIsoDate(_birthDateController.text),
            baptismDate: _toIsoDate(_baptismDateController.text),
            admissionDate: _toIsoDate(_admissionDateController.text),
            consecrationDate:
                _toIsoDate(_consecrationDateController.text),
          );
```

- [ ] **Step 16.9: Flutter analyze**

```
flutter analyze lib/features/members/presentation/pages/create_member_page.dart
```

Expected: no errors.

- [ ] **Step 16.10: Commit**

```
git add atos_logos_mobile/lib/features/members/presentation/pages/create_member_page.dart
git commit -m "feat(mobile): expand create-member form with identity, filiação and consecração fields"
```

---

## Task 17: Mobile — mirror changes in `EditMemberPage`

**Files:**
- Modify: `atos_logos_mobile/lib/features/members/presentation/pages/edit_member_page.dart`

- [ ] **Step 17.1: Read the current page structure**

Run:
```
npx grep -n "TextEditingController\|AccordionSection\|_cpfController\|_onSubmit\|updateMemberUserData" atos_logos_mobile/lib/features/members/presentation/pages/edit_member_page.dart
```

Map the existing controllers and section layout (it likely mirrors the create page).

- [ ] **Step 17.2: Apply the same set of additions as Task 16**

In the edit page, add:
- Imports for `sex.dart`, `civil_status.dart`, `mask_text_input_formatter`.
- Controllers: `_rgController`, `_fatherNameController`, `_motherNameController`, `_consecrationDateController`.
- State: `_selectedSex`, `_selectedCivilStatus`, `_filiationExpanded`.
- CPF mask application on the existing CPF field.
- New RG + Sexo row and Estado Civil field inside "Informações Pessoais".
- New "Filiação" accordion section between Pessoais and Eclesiásticos.
- `Data de Consagração` field inside "Dados Eclesiásticos".
- Pre-populate controllers & dropdown selections from the incoming `MemberProfile` (use the same pre-fill pattern the existing controllers use — typically in `initState` or on a `BlocListener`).

For pre-fill of `Sex` / `CivilStatus`, convert the string coming from the API (`'MALE'`, `'FEMALE'`, …) into the enum. Helper at the top of the state class:

```dart
  Sex? _sexFromWire(String? wire) {
    switch (wire) {
      case 'MALE':
        return Sex.male;
      case 'FEMALE':
        return Sex.female;
      default:
        return null;
    }
  }

  CivilStatus? _civilStatusFromWire(String? wire) {
    switch (wire) {
      case 'SINGLE':
        return CivilStatus.single;
      case 'MARRIED':
        return CivilStatus.married;
      case 'DIVORCED':
        return CivilStatus.divorced;
      case 'WIDOWED':
        return CivilStatus.widowed;
      case 'SEPARATED':
        return CivilStatus.separated;
      case 'STABLE_UNION':
        return CivilStatus.stableUnion;
      default:
        return null;
    }
  }
```

- [ ] **Step 17.3: Update the submit call to `updateMemberUserData`**

Add the 5 identity fields + (if applicable) `consecrationDate` when a separate MemberProfile update call exists on this page. `consecrationDate` lives on `MemberProfile`, not `User`, so whichever call handles profile updates needs it.

```dart
rg: _rgController.text.trim(),
sex: _selectedSex?.wireValue,
civilStatus: _selectedCivilStatus?.wireValue,
fatherName: _fatherNameController.text.trim(),
motherName: _motherNameController.text.trim(),
```

- [ ] **Step 17.4: Flutter analyze**

```
flutter analyze lib/features/members/presentation/pages/edit_member_page.dart
```

Expected: no errors.

- [ ] **Step 17.5: Commit**

```
git add atos_logos_mobile/lib/features/members/presentation/pages/edit_member_page.dart
git commit -m "feat(mobile): expand edit-member form with identity, filiação and consecração fields"
```

---

## Task 18: Mobile — full analyze + build

**Files:** (no edits — verification only)

- [ ] **Step 18.1: Full analyze**

Run inside `atos_logos_mobile/`:
```
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 18.2: Run unit tests**

```
flutter test
```

Expected: all green. If an existing test serialized an older `UserProfileUser` / `MemberProfile` shape, extend the fixture to include the new fields or confirm the test doesn't hit them (nullable additions shouldn't break existing tests).

- [ ] **Step 18.3: Build for the primary target**

Per the project rule (always verify real build before done):

```
flutter build apk --debug
```

Expected: clean build.

---

## Task 19: End-to-end smoke test (manual, against running backend)

**Files:** (no edits — verification only)

- [ ] **Step 19.1: Boot backend**

Inside `atos-logos-backend/`:
```
npm run start:dev
```

- [ ] **Step 19.2: Boot mobile (choose a device/emulator)**

Inside `atos_logos_mobile/`:
```
flutter run
```

- [ ] **Step 19.3: Exercise the Create Member flow**

Log in as a secretary/admin. Navigate to Members → New Member. Fill every new field (RG, Sexo, Estado Civil, Nome do Pai, Nome da Mãe, Data de Consagração). Submit.

Expected: 201 response; member appears in the list. Re-open the member in edit mode and confirm every new field round-tripped.

- [ ] **Step 19.4: Exercise the Edit Member flow**

Edit an existing member — change each new field and save. Reload the member and verify the change persisted.

- [ ] **Step 19.5: Report status and commit any fixup**

If issues surface, fix inline, commit per-fix, and re-verify. If the smoke test is clean, nothing else to commit.

---

## Post-Checklist

- [ ] All 19 tasks marked complete.
- [ ] Backend: `npm run build` green, `npx jest` green, coverage gaps on new lines closed (or documented).
- [ ] Mobile: `flutter analyze` clean, `flutter test` green, `flutter build apk --debug` green.
- [ ] Manual smoke test passed on both Create and Edit flows.
- [ ] All commits pushed (if the user asks for a PR, follow the gh workflow — do not push/open a PR without explicit ask).
