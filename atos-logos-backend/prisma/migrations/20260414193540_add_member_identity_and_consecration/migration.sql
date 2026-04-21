-- CreateEnum
CREATE TYPE "Sex" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "CivilStatus" AS ENUM ('SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED', 'STABLE_UNION');

-- AlterTable
ALTER TABLE "member_profiles" ADD COLUMN     "consecrationDate" DATE;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "civilStatus" "CivilStatus",
ADD COLUMN     "fatherName" TEXT,
ADD COLUMN     "motherName" TEXT,
ADD COLUMN     "rg" TEXT,
ADD COLUMN     "sex" "Sex";
