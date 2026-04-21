import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { UpdateChurchDto } from './dto/update-church.dto';

@Injectable()
export class ChurchesService {
  constructor(private prisma: PrismaService) {}

  async findOne(churchId: string) {
    const church = await this.prisma.church.findUnique({
      where: { id: churchId },
      include: { branches: true },
    });
    if (!church) {
      throw new NotFoundException('Church not found');
    }
    return church;
  }

  async update(churchId: string, dto: UpdateChurchDto) {
    return this.prisma.church.update({
      where: { id: churchId },
      data: dto,
    });
  }
}
