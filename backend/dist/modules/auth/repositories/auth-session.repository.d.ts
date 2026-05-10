import { Repository } from "typeorm";
import { AuthSession } from "../entities/auth-session.entity";
export declare class AuthSessionRepository {
    private readonly repository;
    constructor(repository: Repository<AuthSession>);
    createSession(params: {
        userId: string;
        tokenHash: string;
        expiresAt: Date;
        userAgent?: string | null;
    }): Promise<AuthSession>;
    findActiveByTokenHash(tokenHash: string): Promise<AuthSession | null>;
    revokeByTokenHash(tokenHash: string): Promise<boolean>;
}
