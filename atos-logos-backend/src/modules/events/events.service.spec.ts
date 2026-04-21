import { Test, TestingModule } from '@nestjs/testing';
import { EventsService } from './events.service';
import { PrismaService } from '../../prisma/prisma.service';

const mockEventModel = {
  findMany: jest.fn(),
  findFirst: jest.fn(),
  count: jest.fn(),
  create: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
};

const mockPrismaService = {
  event: mockEventModel,
  eventSchedule: {
    findFirst: jest.fn(),
    create: jest.fn(),
    delete: jest.fn(),
  },
  forTenant: jest.fn(() => ({
    event: mockEventModel,
  })),
};

describe('EventsService', () => {
  let service: EventsService;
  let prisma: typeof mockPrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EventsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<EventsService>(EventsService);
    prisma = module.get(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('EventsService - findAll', () => {
    it('should return only future events sorted by startsAt ascending when upcoming is true', async () => {
      // Given — a tenant with no events yet (mocked) and upcoming=true
      const churchId = 'church-uuid';
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is called with the upcoming flag
      await service.findAll(churchId, 1, 20, undefined, true);

      // Then — Prisma is queried for events with `startsAt >= now` sorted ASC
      expect(mockEventModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            startsAt: expect.objectContaining({ gte: expect.any(Date) }),
          }),
          orderBy: { startsAt: 'asc' },
        }),
      );
    });

    it('should combine the type filter with the upcoming filter when both are provided', async () => {
      // Given — a tenant and both filters set
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is called with type=SERVICE and upcoming=true
      await service.findAll('church-uuid', 1, 20, 'SERVICE' as any, true);

      // Then — both filters are AND-merged in the where clause
      expect(mockEventModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            type: 'SERVICE',
            startsAt: expect.objectContaining({ gte: expect.any(Date) }),
          }),
        }),
      );
    });

    it('should return events sorted descending when upcoming is explicitly false', async () => {
      // Given — no events yet, upcoming=false
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is invoked
      await service.findAll('church-uuid', 1, 20, undefined, false);

      // Then — the ordering defaults to newest-first (DESC)
      expect(mockEventModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          orderBy: { startsAt: 'desc' },
        }),
      );
    });

    it('should return events sorted descending when the upcoming flag is omitted', async () => {
      // Given — no events, no upcoming argument
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is called with only the required args
      await service.findAll('church-uuid', 1, 20);

      // Then — the default ordering is newest-first (DESC)
      expect(mockEventModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          orderBy: { startsAt: 'desc' },
        }),
      );
    });

    it('should return an empty page shape when no events exist for the tenant', async () => {
      // Given — the store has no events for the tenant
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is called
      const result = await service.findAll('church-uuid', 1, 20);

      // Then — the response is an empty, well-formed paginated envelope
      expect(result).toEqual(
        expect.objectContaining({
          data: [],
          total: 0,
        }),
      );
    });

    it('should honour the requested page and limit in the Prisma query', async () => {
      // Given — page 3 of a 5-per-page listing
      mockEventModel.findMany.mockResolvedValue([]);
      mockEventModel.count.mockResolvedValue(0);

      // When — findAll is called with page=3, limit=5
      await service.findAll('church-uuid', 3, 5);

      // Then — Prisma is asked to skip 10 rows and take 5 (offset pagination)
      expect(mockEventModel.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          skip: 10,
          take: 5,
        }),
      );
    });
  });
});
