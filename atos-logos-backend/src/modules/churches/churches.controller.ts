import { Controller, Get, Patch, Body, UseGuards } from '@nestjs/common';
import { ChurchesService } from './churches.service';
import { UpdateChurchDto } from './dto/update-church.dto';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';
import { Role } from '@prisma/client';

@Controller('churches')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ChurchesController {
  constructor(private readonly churchesService: ChurchesService) {}

  @Get('me')
  async findMine(@CurrentUser() user: AuthenticatedUser) {
    return this.churchesService.findOne(user.churchId);
  }

  @Patch('me')
  @Roles(Role.ADMIN)
  async updateMine(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateChurchDto,
  ) {
    return this.churchesService.update(user.churchId, dto);
  }
}
