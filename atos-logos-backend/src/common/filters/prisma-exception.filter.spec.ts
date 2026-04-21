import { ArgumentsHost, HttpStatus } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaExceptionFilter } from './prisma-exception.filter';

/**
 * Builds a minimal ArgumentsHost that exposes a response object with
 * jest-spy status/json so we can assert the HTTP shape the filter
 * produces. Only the pieces Nest actually touches are implemented.
 */
function makeHost() {
  const json = jest.fn();
  const status = jest.fn().mockReturnValue({ json });
  const response = { status };
  const host = {
    switchToHttp: () => ({ getResponse: () => response }),
  } as unknown as ArgumentsHost;
  return { host, status, json };
}

function makeKnownError(
  code: string,
  meta?: Record<string, unknown>,
): Prisma.PrismaClientKnownRequestError {
  return new Prisma.PrismaClientKnownRequestError('boom', {
    code,
    clientVersion: 'test',
    meta,
  });
}

describe('PrismaExceptionFilter', () => {
  let filter: PrismaExceptionFilter;

  beforeEach(() => {
    filter = new PrismaExceptionFilter();
  });

  it('should map P2002 (unique violation) to 409 with the conflicting field(s)', () => {
    const { host, status, json } = makeHost();

    filter.catch(makeKnownError('P2002', { target: ['email'] }), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.CONFLICT);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: HttpStatus.CONFLICT,
        message: expect.stringContaining('email'),
      }),
    );
  });

  it('should fall back to a generic field label when P2002 has no target meta', () => {
    const { host, json } = makeHost();

    filter.catch(makeKnownError('P2002'), host);

    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        message: expect.stringContaining('field'),
      }),
    );
  });

  it('should map P2025 (record not found) to 404', () => {
    const { host, status, json } = makeHost();

    filter.catch(makeKnownError('P2025'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.NOT_FOUND);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({ statusCode: HttpStatus.NOT_FOUND }),
    );
  });

  it('should map P2003 (foreign key violation) to 409 instead of a generic 500', () => {
    // Given — a Prisma FK violation like the one that was slipping
    // through on branch delete. This is the exact regression case.
    const { host, status, json } = makeHost();

    // When — the filter handles it
    filter.catch(makeKnownError('P2003'), host);

    // Then — caller sees 409 Conflict, not 500
    expect(status).toHaveBeenCalledWith(HttpStatus.CONFLICT);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: HttpStatus.CONFLICT,
        error: 'Conflict',
        message: expect.stringMatching(/vinculad/i),
      }),
    );
  });

  it('should map unknown Prisma codes to 500 with a generic message', () => {
    const { host, status, json } = makeHost();

    filter.catch(makeKnownError('P9999'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);
    expect(json).toHaveBeenCalledWith(
      expect.objectContaining({
        statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
        message: 'An unexpected database error occurred',
      }),
    );
  });
});
