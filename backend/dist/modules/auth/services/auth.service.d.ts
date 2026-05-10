import { ConfigService } from "@nestjs/config";
import { ObjectId } from "mongodb";
import { CreateUserDto } from "../../users/dto/create-user.dto";
import { UserService } from "../../users/services/user.service";
import { AuthSessionRepository } from "../repositories/auth-session.repository";
import { toPublicUserProfile } from "../../users/mappers/user-response.mapper";
import { LoginDto } from "../dto/login.dto";
export interface AuthResponse {
    access_token: string;
    token_type: "Bearer";
    expires_at: string;
    user: ReturnType<typeof toPublicUserProfile>;
}
export declare class AuthService {
    private readonly userService;
    private readonly authSessionRepository;
    private readonly configService;
    constructor(userService: UserService, authSessionRepository: AuthSessionRepository, configService: ConfigService);
    register(createUserDto: CreateUserDto, userAgent?: string | null): Promise<AuthResponse>;
    login(loginDto: LoginDto, userAgent?: string | null): Promise<AuthResponse>;
    logout(accessToken: string): Promise<{
        message: string;
    }>;
    validateToken(accessToken: string): Promise<{
        user: import("../../users/entities/user.entity").User;
        id: ObjectId;
        tokenHash: string;
        userId: ObjectId;
        userAgent: string | null;
        expiresAt: Date;
        revokedAt: Date | null;
        createdAt: Date;
    }>;
    private createSession;
    private buildAuthResponse;
}
