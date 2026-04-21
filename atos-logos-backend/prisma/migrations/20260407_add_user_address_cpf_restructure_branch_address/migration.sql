-- AlterTable: Branch — replace "address" with structured address fields
ALTER TABLE "branches" DROP COLUMN IF EXISTS "address";
ALTER TABLE "branches" ADD COLUMN "country" TEXT;
ALTER TABLE "branches" ADD COLUMN "state" TEXT;
ALTER TABLE "branches" ADD COLUMN "city" TEXT;
ALTER TABLE "branches" ADD COLUMN "neighborhood" TEXT;
ALTER TABLE "branches" ADD COLUMN "street" TEXT;
ALTER TABLE "branches" ADD COLUMN "number" TEXT;

-- AlterTable: User — add CPF and address fields
ALTER TABLE "users" ADD COLUMN "cpf" TEXT;
ALTER TABLE "users" ADD COLUMN "country" TEXT;
ALTER TABLE "users" ADD COLUMN "state" TEXT;
ALTER TABLE "users" ADD COLUMN "city" TEXT;
ALTER TABLE "users" ADD COLUMN "neighborhood" TEXT;
ALTER TABLE "users" ADD COLUMN "street" TEXT;
ALTER TABLE "users" ADD COLUMN "number" TEXT;
ALTER TABLE "users" ADD COLUMN "complement" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "users_cpf_key" ON "users"("cpf");
