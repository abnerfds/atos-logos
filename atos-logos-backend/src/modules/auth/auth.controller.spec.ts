import { Test, TestingModule } from '@nestjs/testing';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

describe('AuthController', () => {
  let controller: AuthController;
  let service: jest.Mocked<AuthService>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AuthController],
      providers: [
        {
          provide: AuthService,
          useValue: {
            signupAdmin: jest.fn(),
            login: jest.fn(),
            selectChurch: jest.fn(),
            refresh: jest.fn(),
            logoutRefresh: jest.fn(),
            getProfile: jest.fn(),
            updateProfile: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<AuthController>(AuthController);
    service = module.get(AuthService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('signupAdmin', () => {
    it('should forward the DTO to AuthService.signupAdmin and return its result', async () => {
      const dto = {
        name: 'Pastor',
        email: 'admin@church.com',
        password: 'pwd123',
        churchName: 'Grace',
      };
      const expected = { user: { id: 'u1' }, church: { id: 'c1' }, branch: { id: 'b1' } };
      service.signupAdmin.mockResolvedValue(expected as any);

      const result = await controller.signupAdmin(dto);

      expect(service.signupAdmin).toHaveBeenCalledWith(dto);
      expect(result).toBe(expected);
    });
  });

  describe('login', () => {
    it('should forward email+password to AuthService.login', async () => {
      service.login.mockResolvedValue({
        access_token: 'acc',
        refresh_token: 'rfr',
      } as any);

      const result = await controller.login({
        email: 'admin@church.com',
        password: 'pwd123',
      });

      expect(service.login).toHaveBeenCalledWith('admin@church.com', 'pwd123');
      expect(result).toEqual({ access_token: 'acc', refresh_token: 'rfr' });
    });
  });

  describe('selectChurch', () => {
    it('should forward selectionToken and churchId to AuthService.selectChurch', async () => {
      service.selectChurch.mockResolvedValue({
        access_token: 'acc',
        refresh_token: 'rfr',
      } as any);

      const result = await controller.selectChurch({
        selectionToken: 'sel-token',
        churchId: 'c1',
      });

      expect(service.selectChurch).toHaveBeenCalledWith('sel-token', 'c1');
      expect(result).toEqual({ access_token: 'acc', refresh_token: 'rfr' });
    });
  });

  describe('refresh', () => {
    it('should forward refreshToken to AuthService.refresh', async () => {
      service.refresh.mockResolvedValue({
        access_token: 'new-acc',
        refresh_token: 'new-rfr',
      } as any);

      const result = await controller.refresh({ refreshToken: 'old-rfr' });

      expect(service.refresh).toHaveBeenCalledWith('old-rfr');
      expect(result).toEqual({
        access_token: 'new-acc',
        refresh_token: 'new-rfr',
      });
    });
  });

  describe('logout', () => {
    it('should forward refreshToken to AuthService.logoutRefresh and return void', async () => {
      service.logoutRefresh.mockResolvedValue(undefined);

      const result = await controller.logout({ refreshToken: 'rfr' });

      expect(service.logoutRefresh).toHaveBeenCalledWith('rfr');
      expect(result).toBeUndefined();
    });
  });

  describe('getProfile', () => {
    it('should forward userId and churchId from CurrentUser to AuthService.getProfile', async () => {
      const user = {
        userId: 'u1',
        email: 'a@b.com',
        churchId: 'c1',
        branchId: 'b1',
        role: 'ADMIN' as const,
      };
      const expected = { user: { id: 'u1' } };
      service.getProfile.mockResolvedValue(expected as any);

      const result = await controller.getProfile(user);

      expect(service.getProfile).toHaveBeenCalledWith('u1', 'c1');
      expect(result).toBe(expected);
    });
  });

  describe('updateMyProfile', () => {
    it('should forward userId and DTO to AuthService.updateProfile', async () => {
      const user = {
        userId: 'u1',
        email: 'a@b.com',
        churchId: 'c1',
        branchId: 'b1',
        role: 'ADMIN' as const,
      };
      const dto = { name: 'Updated' };
      service.updateProfile.mockResolvedValue({ id: 'u1', name: 'Updated' } as any);

      const result = await controller.updateMyProfile(user, dto);

      expect(service.updateProfile).toHaveBeenCalledWith('u1', dto);
      expect(result).toEqual({ id: 'u1', name: 'Updated' });
    });
  });
});
