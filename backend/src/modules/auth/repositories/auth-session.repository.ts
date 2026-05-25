import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { ObjectId } from "mongodb";
import { Repository } from "typeorm";
import { AuthSession } from "../entities/auth-session.entity";
import { User } from "../../users/entities/user.entity";

@Injectable()
export class AuthSessionRepository {
  constructor(
    @InjectRepository(AuthSession)
    private readonly repository: Repository<AuthSession>
  ) {}

  async createSession(params: {
    userId: string;
    tokenHash: string;
    expiresAt: Date;
    userAgent?: string | null;
  }): Promise<AuthSession> {
    const session = this.repository.create({
      userId: new ObjectId(params.userId) as any,
      tokenHash: params.tokenHash,
      expiresAt: params.expiresAt,
      userAgent: params.userAgent ?? null,
      revokedAt: null
    });

    return await this.repository.save(session);
  }

  async findActiveByTokenHash(tokenHash: string): Promise<AuthSession | null> {
    const session = await this.repository.findOne({ where: { tokenHash } });
    if (!session) return null;
    if (session.revokedAt != null) return null;
    if (new Date(session.expiresAt) <= new Date()) return null;
    return session;
  }

  async revokeByTokenHash(tokenHash: string): Promise<boolean> {
    const result = await this.repository.update({ tokenHash }, { revokedAt: new Date() });
    return (result.affected ?? 0) > 0;
  }
}