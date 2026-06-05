import { BadRequestException, Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { ObjectId } from "mongodb";
import { CreateUserDto } from "../../users/dto/create-user.dto";
import { UserService } from "../../users/services/user.service";
import { AuthSessionRepository } from "../repositories/auth-session.repository";
import { addHours, generateSessionToken, hashToken, verifyPassword } from "../../../common/security/crypto.util";
import { toPublicUserProfile } from "../../users/mappers/user-response.mapper";
import { LoginDto } from "../dto/login.dto";

export interface AuthResponse {
  access_token: string;
  token_type: "Bearer";
  expires_at: string;
  user: ReturnType<typeof toPublicUserProfile>;
}

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly authSessionRepository: AuthSessionRepository,
    private readonly configService: ConfigService
  ) {}

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  async register(createUserDto: CreateUserDto, userAgent?: string | null): Promise<AuthResponse> {
    const user = await this.userService.create({
      ...createUserDto,
      email: this.normalizeEmail(createUserDto.email)
    });
    const session = await this.createSession(user, userAgent);

    return this.buildAuthResponse(user, session.token, session.expiresAt);
  }

  async login(loginDto: LoginDto, userAgent?: string | null): Promise<AuthResponse> {
    const user = await this.userService.findByEmail(this.normalizeEmail(loginDto.email));
    if (!user) {
      throw new UnauthorizedException("Invalid email or password");
    }

    if (!verifyPassword(loginDto.password, user.passwordHash)) {
      throw new UnauthorizedException("Invalid email or password");
    }

    const session = await this.createSession(user, userAgent);
    return this.buildAuthResponse(user, session.token, session.expiresAt);
  }

  async logout(accessToken: string): Promise<{ message: string }> {
    const tokenHash = hashToken(accessToken);
    const revoked = await this.authSessionRepository.revokeByTokenHash(tokenHash);

    if (!revoked) {
      throw new UnauthorizedException("Session not found");
    }

    return { message: "Signed out successfully" };
  }

  async validateToken(accessToken: string) {
    const tokenHash = hashToken(accessToken);
    const session = await this.authSessionRepository.findActiveByTokenHash(tokenHash);

    if (!session) {
      throw new UnauthorizedException("Invalid or expired session");
    }

    const userId = session.userId instanceof ObjectId ? session.userId.toHexString() : String(session.userId);
    const user = await this.userService.findById(userId);

    return { ...session, user };
  }

  private async createSession(user: Awaited<ReturnType<UserService["create"]>>, userAgent?: string | null) {
    const accessToken = generateSessionToken();
    const tokenHash = hashToken(accessToken);
    const sessionTtlHours = this.configService.get<number>("AUTH_SESSION_TTL_HOURS") || 168;
    const expiresAt = addHours(new Date(), sessionTtlHours);

    await this.authSessionRepository.createSession({
      userId: user.id?.toHexString?.() ?? String(user.id),
      tokenHash,
      expiresAt,
      userAgent: userAgent ?? null
    });

    return { token: accessToken, expiresAt };
  }

  private buildAuthResponse(user: Awaited<ReturnType<UserService["create"]>>, accessToken: string, expiresAt: Date): AuthResponse {
    return {
      access_token: accessToken,
      token_type: "Bearer",
      expires_at: expiresAt.toISOString(),
      user: toPublicUserProfile(user)
    };
  }
}