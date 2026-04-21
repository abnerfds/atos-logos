# Expand Member Identity Fields — Design

**Date:** 2026-04-14
**Status:** Approved (awaiting spec review)
**Scope:** Backend (NestJS/Prisma) + Mobile (Flutter)

## Context

The Atos Logos data model splits a "member" across two entities:

- `User` — global identity (one per person, shared across churches)
- `MemberProfile` — per-church ecclesiastical profile

The secretariat needs to record additional identity and ecclesiastical information during/after member registration. This spec expands those two entities with the missing fields and wires them through DTOs and the Flutter model.

Several initially requested fields were **dropped** after review because equivalent structures already exist:

| Requested | Decision |
|---|---|
| `cpf` | Skipped — already on `User`. |
| `birthDate`, `baptismDate` | Skipped — already on `MemberProfile`. |
| `acceptanceDate` | Skipped — covered by existing `admissionDate`. |
| `situation` enum | Skipped — covered by `Membership.status` (`ACTIVE`/`INACTIVE`/`TRANSFERRED`). |
| `function` | Skipped — covered by the `MemberPosition` table. |
| `sector` | Skipped — covered by `Branch` (the member's congregation). |

## Goals

Add the following fields and make them fully usable end-to-end (Prisma → DTO validation → Flutter model → form UI grouping).

### `User` — new fields (global identity)

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `rg` | `String` | yes | Identity card number, no strict format enforced (varies by state) |
| `sex` | `Sex` enum | yes | Values: `MALE`, `FEMALE` |
| `civilStatus` | `CivilStatus` enum | yes | Values: `SINGLE`, `MARRIED`, `DIVORCED`, `WIDOWED`, `SEPARATED`, `STABLE_UNION` |
| `fatherName` | `String` | yes | |
| `motherName` | `String` | yes | |

Rationale for placing them on `User`: identity-level data that doesn't change if the user is registered in multiple churches. Consistent with `cpf` already on `User`.

### `MemberProfile` — new field (per-church ecclesiastical)

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `consecrationDate` | `DateTime @db.Date` | yes | Date of ministerial consecration |

### New Prisma enums

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

All new columns are **optional** in the DB. This avoids forcing a default value onto existing rows and lets the secretariat save partial records.

## Non-Goals

- Renaming `admissionDate` → `memberSince` (decided: keep existing name).
- Adding wedding/death/transfer dates (out of scope for this pass).
- Changes to `Membership`, `MemberPosition`, or `Branch`.
- Any changes to auth/registration flow beyond widening the user payload.

## Architecture

### Backend (NestJS + Prisma)

1. **Schema update** — edit `atos-logos-backend/prisma/schema.prisma`:
   - Add `Sex` and `CivilStatus` enums in the enums block.
   - Add the 5 new fields to `model User`.
   - Add `consecrationDate` to `model MemberProfile`.

2. **Migration** — `prisma migrate dev --name add_member_identity_and_consecration`. All new columns are nullable, so no backfill is required.

3. **DTO updates** — in the auth/users module (wherever `CreateUserDto` / `UpdateUserDto` live):
   - Add the 5 new fields with `class-validator`:
     - `rg?: string` — `@IsOptional() @IsString() @Length(1, 20)`
     - `sex?: Sex` — `@IsOptional() @IsEnum(Sex)`
     - `civilStatus?: CivilStatus` — `@IsOptional() @IsEnum(CivilStatus)`
     - `fatherName?: string`, `motherName?: string` — `@IsOptional() @IsString() @Length(1, 120)`
   - Enums are imported from `@prisma/client`.

4. **MemberProfile DTOs** — add `consecrationDate?: Date`:
   - `@IsOptional() @IsISO8601() @Type(() => Date)` (match the existing pattern used by `birthDate`/`baptismDate` in the module).

5. **Service / repository layer** — pass-through. No new business rules. Spread the new fields into the Prisma `create`/`update` payloads.

### Mobile (Flutter)

Location: `atos_logos_mobile/lib/`.

1. **Enum definitions** — new Dart enums `Sex` and `CivilStatus` with `@JsonEnum(alwaysCreate: true)` so JSON serialization matches the backend (UPPER_SNAKE_CASE string values).

2. **Model updates** — extend the `User` and `MemberProfile` models (the ones using `json_serializable`):
   - Add nullable fields mirroring the backend.
   - Regenerate `.g.dart` via `dart run build_runner build --delete-conflicting-outputs`.

3. **Form grouping** — the member edit/create form is restructured into three visual sections (using existing section widget if one exists, otherwise a simple `ExpansionTile`/`Card` per section):
   - **Pessoais:** name, sex, RG, CPF, civil status, birth date
   - **Filiação:** father name, mother name
   - **Eclesiástico:** admission date, baptism date, consecration date, position (existing)

4. **Input formatting:**
   - CPF and RG use `mask_text_input_formatter`.
   - Dates use the existing date picker pattern.

## Data Flow

No change to request flow. The member profile creation/edit screen sends the expanded payload; backend validates via DTOs and writes via Prisma. Auth flow is unchanged (new fields are not required at registration).

## Error Handling

- All new fields being optional means missing values produce no validation errors.
- Enum values outside the allowed set produce a 400 via `@IsEnum`.
- Invalid ISO date for `consecrationDate` produces a 400 via `@IsISO8601`.

## Testing

- **Backend unit tests:** extend existing DTO validation tests to cover accepted/rejected values for `Sex`, `CivilStatus`, `consecrationDate`. Follow the project testing strategy in `.ai_docs/testing_strategy.md`.
- **Backend integration tests:** one happy-path test that POSTs a user + member profile with all new fields populated and asserts round-trip read.
- **Flutter tests:** widget tests for the three form sections — verify each field renders, accepts valid input, and shows the masked value where applicable.
- **Coverage gate:** after implementation, run coverage and close gaps to 100% per the project's coverage policy.

## Migration / Rollout

- Single Prisma migration, additive only (no column removals or type changes).
- Zero downtime: all new columns nullable; existing rows remain valid.
- Mobile app requires a release that includes the new model; older app versions continue to work because they simply ignore unknown fields on GET responses (JsonSerializable default).

## Open Questions

None at spec write time. Any ambiguity should be flagged during the implementation-plan stage.
