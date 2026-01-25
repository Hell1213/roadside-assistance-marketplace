import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
} from '@nestjs/common';

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse();

    // Log for debugging during development (we keep response generic for security).
    // eslint-disable-next-line no-console
    console.error(exception);

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const payload = exception.getResponse();
      return response.status(status).json({
        code: 'HTTP_EXCEPTION',
        status,
        message:
          typeof payload === 'string'
            ? payload
            : (payload as any)?.message ?? exception.message,
        details: typeof payload === 'object' ? payload : undefined,
      });
    }

    return response.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      code: 'INTERNAL_SERVER_ERROR',
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      message: 'Internal server error',
    });
  }
}

