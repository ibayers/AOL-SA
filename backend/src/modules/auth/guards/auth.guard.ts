import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from "@nestjs/common";
import { Request } from "express";
import { AuthService } from "../services/auth.service";
import { toPublicUserProfile } from "../../users/mappers/user-response.mapper";

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request & { user?: ReturnType<typeof toPublicUserProfile>; accessToken?: string }>();
    const authorizationHeader = request.headers.authorization;

    if (!authorizationHeader?.startsWith("Bearer ")) {
      throw new UnauthorizedException("Missing access token");
    }

    const accessToken = authorizationHeader.slice(7).trim();
    if (!accessToken) {
      throw new UnauthorizedException("Missing access token");
    }

    const session = await this.authService.validateToken(accessToken);
    request.user = toPublicUserProfile(session.user);
    request.accessToken = accessToken;
    return true;
  }
}