"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const mongodb_1 = require("mongodb");
const user_service_1 = require("../../users/services/user.service");
const auth_session_repository_1 = require("../repositories/auth-session.repository");
const crypto_util_1 = require("../../../common/security/crypto.util");
const user_response_mapper_1 = require("../../users/mappers/user-response.mapper");
let AuthService = class AuthService {
    constructor(userService, authSessionRepository, configService) {
        this.userService = userService;
        this.authSessionRepository = authSessionRepository;
        this.configService = configService;
    }
    async register(createUserDto, userAgent) {
        const user = await this.userService.create(createUserDto);
        const session = await this.createSession(user, userAgent);
        return this.buildAuthResponse(user, session.token, session.expiresAt);
    }
    async login(loginDto, userAgent) {
        const user = await this.userService.findByEmail(loginDto.email);
        if (!user) {
            throw new common_1.UnauthorizedException("Invalid email or password");
        }
        if (!(0, crypto_util_1.verifyPassword)(loginDto.password, user.passwordHash)) {
            throw new common_1.UnauthorizedException("Invalid email or password");
        }
        const session = await this.createSession(user, userAgent);
        return this.buildAuthResponse(user, session.token, session.expiresAt);
    }
    async logout(accessToken) {
        const tokenHash = (0, crypto_util_1.hashToken)(accessToken);
        const revoked = await this.authSessionRepository.revokeByTokenHash(tokenHash);
        if (!revoked) {
            throw new common_1.UnauthorizedException("Session not found");
        }
        return { message: "Signed out successfully" };
    }
    async validateToken(accessToken) {
        const tokenHash = (0, crypto_util_1.hashToken)(accessToken);
        const session = await this.authSessionRepository.findActiveByTokenHash(tokenHash);
        if (!session) {
            throw new common_1.UnauthorizedException("Invalid or expired session");
        }
        const userId = session.userId instanceof mongodb_1.ObjectId ? session.userId.toHexString() : String(session.userId);
        const user = await this.userService.findById(userId);
        return { ...session, user };
    }
    async createSession(user, userAgent) {
        const accessToken = (0, crypto_util_1.generateSessionToken)();
        const tokenHash = (0, crypto_util_1.hashToken)(accessToken);
        const sessionTtlHours = this.configService.get("AUTH_SESSION_TTL_HOURS") || 168;
        const expiresAt = (0, crypto_util_1.addHours)(new Date(), sessionTtlHours);
        await this.authSessionRepository.createSession({
            userId: user.id?.toHexString?.() ?? String(user.id),
            tokenHash,
            expiresAt,
            userAgent: userAgent ?? null
        });
        return { token: accessToken, expiresAt };
    }
    buildAuthResponse(user, accessToken, expiresAt) {
        return {
            access_token: accessToken,
            token_type: "Bearer",
            expires_at: expiresAt.toISOString(),
            user: (0, user_response_mapper_1.toPublicUserProfile)(user)
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [user_service_1.UserService,
        auth_session_repository_1.AuthSessionRepository,
        config_1.ConfigService])
], AuthService);
//# sourceMappingURL=auth.service.js.map