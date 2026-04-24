-- AlterTable
ALTER TABLE "ebd_attendances" ALTER COLUMN "isPresent" SET DEFAULT false;

-- AlterTable
ALTER TABLE "ebd_classes" ALTER COLUMN "targetAudience" DROP DEFAULT;
