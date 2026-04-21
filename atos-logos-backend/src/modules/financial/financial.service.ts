import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { TransactionType } from '@prisma/client';

@Injectable()
export class FinancialService {
  constructor(private prisma: PrismaService) {}

  // ── Campaigns ─────────────────────────────────────────────────────────

  async findAllCampaigns(churchId: string) {
    return this.prisma.forTenant(churchId).campaign.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async createCampaign(churchId: string, dto: CreateCampaignDto) {
    return this.prisma.campaign.create({
      data: { churchId, title: dto.title, goalAmount: dto.goalAmount },
    });
  }

  async updateCampaign(churchId: string, campaignId: string, dto: UpdateCampaignDto) {
    const campaign = await this.prisma.forTenant(churchId).campaign.findFirst({
      where: { id: campaignId },
    });
    if (!campaign) throw new NotFoundException('Campaign not found');

    return this.prisma.campaign.update({
      where: { id: campaignId },
      data: dto,
    });
  }

  // ── Transactions ──────────────────────────────────────────────────────

  async findAllTransactions(churchId: string, page = 1, limit = 20, type?: TransactionType) {
    const skip = (page - 1) * limit;
    const where = type ? { type } : {};

    const [data, total] = await Promise.all([
      this.prisma.forTenant(churchId).financialTransaction.findMany({
        where,
        include: { donor: { select: { id: true, name: true } } },
        orderBy: { transactionDate: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.forTenant(churchId).financialTransaction.count({ where }),
    ]);
    return { data, total, page, limit };
  }

  async createTransaction(churchId: string, dto: CreateTransactionDto) {
    return this.prisma.financialTransaction.create({
      data: {
        churchId,
        type: dto.type,
        category: dto.category,
        amount: dto.amount,
        transactionDate: new Date(dto.transactionDate),
        branchId: dto.branchId || null,
        donorUserId: dto.donorUserId || null,
      },
      include: { donor: { select: { id: true, name: true } } },
    });
  }

  // ── Summary ───────────────────────────────────────────────────────────

  async getSummary(churchId: string) {
    const [income, expense] = await Promise.all([
      this.prisma.financialTransaction.aggregate({
        where: { churchId, type: 'INCOME' },
        _sum: { amount: true },
      }),
      this.prisma.financialTransaction.aggregate({
        where: { churchId, type: 'EXPENSE' },
        _sum: { amount: true },
      }),
    ]);

    const totalIncome = Number(income._sum.amount ?? 0);
    const totalExpense = Number(expense._sum.amount ?? 0);

    return {
      totalIncome,
      totalExpense,
      balance: totalIncome - totalExpense,
    };
  }
}
