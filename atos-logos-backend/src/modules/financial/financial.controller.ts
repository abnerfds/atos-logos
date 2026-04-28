import {
  Controller, Get, Post, Patch,
  Body, Param, Query, UseGuards,
} from '@nestjs/common';
import { FinancialService } from './financial.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
import { CreateTransactionDto } from './dto/create-transaction.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { PermissionsGuard } from '../../common/guards/permissions.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { RequirePermissions } from '../../common/decorators/require-permissions.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { Permission } from '../../common/enums/permission.enum';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role, TransactionType } from '@prisma/client';

@Controller('financial')
@UseGuards(JwtAuthGuard, RolesGuard, PermissionsGuard)
export class FinancialController {
  constructor(private readonly financialService: FinancialService) {}

  // ── Campaigns ─────────────────────────────────────────────────────────

  @Get('campaigns')
  @RequirePermissions(Permission.VIEW_CONTRIBUTIONS)
  async findAllCampaigns(@CurrentUser() user: AuthenticatedUser) {
    return this.financialService.findAllCampaigns(user.churchId);
  }

  @Post('campaigns')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.LAUNCH_OFFERINGS)
  async createCampaign(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateCampaignDto,
  ) {
    return this.financialService.createCampaign(user.churchId, dto);
  }

  @Patch('campaigns/:id')
  @Roles(Role.ADMIN)
  @RequirePermissions(Permission.EDIT_TRANSACTIONS)
  async updateCampaign(
    @CurrentUser() user: AuthenticatedUser,
    @Param('id') id: string,
    @Body() dto: UpdateCampaignDto,
  ) {
    return this.financialService.updateCampaign(user.churchId, id, dto);
  }

  // ── Transactions ──────────────────────────────────────────────────────

  @Get('transactions')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.VIEW_CONTRIBUTIONS)
  async findAllTransactions(
    @CurrentUser() user: AuthenticatedUser,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('type') type?: TransactionType,
  ) {
    return this.financialService.findAllTransactions(
      user.churchId,
      page ? parseInt(page) : 1,
      limit ? parseInt(limit) : 20,
      type,
    );
  }

  @Post('transactions')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.LAUNCH_OFFERINGS)
  async createTransaction(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: CreateTransactionDto,
  ) {
    return this.financialService.createTransaction(user.churchId, dto);
  }

  // ── Summary ───────────────────────────────────────────────────────────

  @Get('summary')
  @Roles(Role.ADMIN, Role.SECRETARY)
  @RequirePermissions(Permission.VIEW_CONTRIBUTIONS)
  async getSummary(@CurrentUser() user: AuthenticatedUser) {
    return this.financialService.getSummary(user.churchId);
  }
}
