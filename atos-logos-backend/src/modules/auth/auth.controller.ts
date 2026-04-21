import { Controller, Post, Get, Patch, Body, UseGuards, HttpCode } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AuthService } from './auth.service';
import { SignupAdminDto } from './dto/signup-admin.dto';
import { LoginDto } from './dto/login.dto';
import { SelectChurchDto } from './dto/select-church.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { RefreshDto } from './dto/refresh.dto';
import { JwtAuthGuard } from './jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import type { AuthenticatedUser } from '../../common/interfaces/authenticated-user.interface';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // Tight throttle on account-creation: prevents abuse of the signup endpoint.
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Post('signup-admin')
  async signupAdmin(@Body() body: SignupAdminDto) {
    return this.authService.signupAdmin(body);
  }

  // Tight throttle on login: blocks brute-force attempts (5 per minute per IP).
  @Throttle({ default: { limit: 5, ttl: 60_000 } })
  @Post('login')
  async login(@Body() body: LoginDto) {
    return this.authService.login(body.email, body.password);
  }

  // Tight throttle on church selection: limits token abuse on the 2nd login step.
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post('select-church')
  async selectChurch(@Body() body: SelectChurchDto) {
    return this.authService.selectChurch(body.selectionToken, body.churchId);
  }

  // Refresh endpoint: rotates the presented refresh token and returns a new pair.
  // Throttled a bit more loosely than login because a legitimate mobile client
  // may trigger refresh repeatedly after 60m idle periods.
  @Throttle({ default: { limit: 20, ttl: 60_000 } })
  @Post('refresh')
  async refresh(@Body() body: RefreshDto) {
    return this.authService.refresh(body.refreshToken);
  }

  // Logout from a single device: revokes the presented refresh token.
  // Returns 204 No Content — idempotent and leaks nothing on unknown tokens.
  @HttpCode(204)
  @Post('logout')
  async logout(@Body() body: RefreshDto): Promise<void> {
    await this.authService.logoutRefresh(body.refreshToken);
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async getProfile(@CurrentUser() user: AuthenticatedUser) {
    return this.authService.getProfile(user.userId, user.churchId);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('me')
  async updateMyProfile(
    @CurrentUser() user: AuthenticatedUser,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.authService.updateProfile(user.userId, dto);
  }
}
