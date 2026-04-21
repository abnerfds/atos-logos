import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Response } from 'express';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(PrismaExceptionFilter.name);

  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    this.logger.warn(`Prisma error ${exception.code}: ${exception.message}`);

    switch (exception.code) {
      case 'P2002': {
        const fields = (exception.meta?.target as string[])?.join(', ') || 'field';
        response.status(HttpStatus.CONFLICT).json({
          statusCode: HttpStatus.CONFLICT,
          message: `A record with this ${fields} already exists`,
          error: 'Conflict',
        });
        break;
      }
      case 'P2025':
        response.status(HttpStatus.NOT_FOUND).json({
          statusCode: HttpStatus.NOT_FOUND,
          message: 'Record not found',
          error: 'Not Found',
        });
        break;
      case 'P2003':
        // Foreign key violation — the caller tried to delete/update a
        // row that is still referenced by other rows. Services should
        // pre-check and throw a domain-specific 409, but this is the
        // safety net so the user never sees a generic 500.
        response.status(HttpStatus.CONFLICT).json({
          statusCode: HttpStatus.CONFLICT,
          message:
            'Não é possível completar a operação: existem registros vinculados a este recurso.',
          error: 'Conflict',
        });
        break;
      default:
        response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
          statusCode: HttpStatus.INTERNAL_SERVER_ERROR,
          message: 'An unexpected database error occurred',
          error: 'Internal Server Error',
        });
    }
  }
}
