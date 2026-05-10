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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthSessionRepository = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const mongodb_1 = require("mongodb");
const typeorm_2 = require("typeorm");
const auth_session_entity_1 = require("../entities/auth-session.entity");
let AuthSessionRepository = class AuthSessionRepository {
    constructor(repository) {
        this.repository = repository;
    }
    async createSession(params) {
        const session = this.repository.create({
            userId: new mongodb_1.ObjectId(params.userId),
            tokenHash: params.tokenHash,
            expiresAt: params.expiresAt,
            userAgent: params.userAgent ?? null,
            revokedAt: null
        });
        return await this.repository.save(session);
    }
    async findActiveByTokenHash(tokenHash) {
        return await this.repository.findOne({
            where: {
                tokenHash,
                revokedAt: (0, typeorm_2.IsNull)(),
                expiresAt: (0, typeorm_2.MoreThan)(new Date())
            }
        });
    }
    async revokeByTokenHash(tokenHash) {
        const result = await this.repository.update({ tokenHash }, { revokedAt: new Date() });
        return (result.affected ?? 0) > 0;
    }
};
exports.AuthSessionRepository = AuthSessionRepository;
exports.AuthSessionRepository = AuthSessionRepository = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(auth_session_entity_1.AuthSession)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], AuthSessionRepository);
//# sourceMappingURL=auth-session.repository.js.map