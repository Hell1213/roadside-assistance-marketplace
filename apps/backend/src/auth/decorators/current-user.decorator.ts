import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export type CurrentUser = { userId: string; roles: string[] };

export const CurrentUser = createParamDecorator(
  (data: unknown, ctx: ExecutionContext): CurrentUser => {
    const req = ctx.switchToHttp().getRequest();
    return req.user as CurrentUser;
  },
);


