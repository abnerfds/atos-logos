-- CreateEnum
CREATE TYPE "EbdQuarterStatus" AS ENUM ('ACTIVE', 'FINISHED');

-- CreateTable
CREATE TABLE "ebd_quarters" (
    "id" TEXT NOT NULL,
    "churchId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" "EbdQuarterStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ebd_quarters_pkey" PRIMARY KEY ("id")
);

-- Existing classes need a valid quarter before the new relation becomes required.
INSERT INTO "ebd_quarters" ("id", "churchId", "name", "status", "createdAt", "updatedAt")
SELECT 'legacy-quarter-' || c."id", c."id", 'Legacy Quarter', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
FROM "churches" c
WHERE EXISTS (
    SELECT 1 FROM "ebd_classes" ec WHERE ec."churchId" = c."id"
);

-- AlterTable
ALTER TABLE "ebd_classes"
ADD COLUMN "quarterId" TEXT,
ADD COLUMN "targetAudience" TEXT NOT NULL DEFAULT 'General',
ADD COLUMN "status" BOOLEAN NOT NULL DEFAULT true;

UPDATE "ebd_classes" ec
SET "quarterId" = eq."id"
FROM "ebd_quarters" eq
WHERE eq."churchId" = ec."churchId"
  AND eq."name" = 'Legacy Quarter'
  AND ec."quarterId" IS NULL;

ALTER TABLE "ebd_classes" ALTER COLUMN "quarterId" SET NOT NULL;

-- CreateTable
CREATE TABLE "ebd_class_teachers" (
    "id" TEXT NOT NULL,
    "classId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ebd_class_teachers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ebd_lessons" (
    "id" TEXT NOT NULL,
    "classId" TEXT NOT NULL,
    "number" INTEGER NOT NULL,
    "theme" TEXT NOT NULL,
    "scheduledDate" DATE NOT NULL,
    "isCompleted" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ebd_lessons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ebd_journals" (
    "id" TEXT NOT NULL,
    "lessonId" TEXT NOT NULL,
    "visitorCount" INTEGER NOT NULL DEFAULT 0,
    "offeringAmount" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ebd_journals_pkey" PRIMARY KEY ("id")
);

-- The old attendance rows were event-based. The new EBD journal is lesson-based.
TRUNCATE TABLE "ebd_attendances";

-- DropForeignKey
ALTER TABLE "ebd_attendances" DROP CONSTRAINT "ebd_attendances_classId_fkey";
ALTER TABLE "ebd_attendances" DROP CONSTRAINT "ebd_attendances_eventId_fkey";

-- DropIndex
DROP INDEX "ebd_attendances_classId_eventId_userId_key";

-- AlterTable
ALTER TABLE "ebd_attendances"
DROP COLUMN "classId",
DROP COLUMN "eventId",
ADD COLUMN "lessonId" TEXT NOT NULL,
ADD COLUMN "updatedAt" TIMESTAMP(3) NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "ebd_class_teachers_classId_userId_key" ON "ebd_class_teachers"("classId", "userId");
CREATE UNIQUE INDEX "ebd_lessons_classId_number_key" ON "ebd_lessons"("classId", "number");
CREATE UNIQUE INDEX "ebd_journals_lessonId_key" ON "ebd_journals"("lessonId");
CREATE UNIQUE INDEX "ebd_attendances_lessonId_userId_key" ON "ebd_attendances"("lessonId", "userId");

-- AddForeignKey
ALTER TABLE "ebd_quarters" ADD CONSTRAINT "ebd_quarters_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "churches"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ebd_classes" ADD CONSTRAINT "ebd_classes_quarterId_fkey" FOREIGN KEY ("quarterId") REFERENCES "ebd_quarters"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ebd_class_teachers" ADD CONSTRAINT "ebd_class_teachers_classId_fkey" FOREIGN KEY ("classId") REFERENCES "ebd_classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ebd_class_teachers" ADD CONSTRAINT "ebd_class_teachers_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ebd_lessons" ADD CONSTRAINT "ebd_lessons_classId_fkey" FOREIGN KEY ("classId") REFERENCES "ebd_classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ebd_journals" ADD CONSTRAINT "ebd_journals_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "ebd_lessons"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ebd_attendances" ADD CONSTRAINT "ebd_attendances_lessonId_fkey" FOREIGN KEY ("lessonId") REFERENCES "ebd_lessons"("id") ON DELETE CASCADE ON UPDATE CASCADE;
