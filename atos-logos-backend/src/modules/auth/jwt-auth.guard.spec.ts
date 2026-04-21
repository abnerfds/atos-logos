import { JwtAuthGuard } from './jwt-auth.guard';
import { AuthGuard } from '@nestjs/passport';

describe('JwtAuthGuard', () => {
  it('should inherit from the passport JWT AuthGuard mixin when instantiated', () => {
    // Given — the JwtAuthGuard class extending AuthGuard('jwt') mixin
    // When — a new instance is created
    const guard = new JwtAuthGuard();

    // Then — the instance is a proper AuthGuard('jwt') descendant,
    // meaning `canActivate` will dispatch to the passport-jwt strategy.
    expect(guard).toBeInstanceOf(AuthGuard('jwt'));
  });
});
