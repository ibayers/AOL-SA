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
exports.UserService = void 0;
const common_1 = require("@nestjs/common");
const user_repository_1 = require("../repositories/user.repository");
const crypto_util_1 = require("../../../common/security/crypto.util");
const user_response_mapper_1 = require("../mappers/user-response.mapper");
let UserService = class UserService {
    constructor(userRepository) {
        this.userRepository = userRepository;
    }
    normalizeEmail(email) {
        return email.trim().toLowerCase();
    }
    async create(createUserDto) {
        const email = this.normalizeEmail(createUserDto.email);
        const existingUser = await this.userRepository.findByEmail(email);
        if (existingUser) {
            throw new common_1.BadRequestException("User with this email already exists");
        }
        return await this.userRepository.create({
            email,
            name: createUserDto.name,
            passwordHash: (0, crypto_util_1.hashPassword)(createUserDto.password),
            role: createUserDto.role ?? "user",
            avatarUrl: createUserDto.avatarUrl ?? null,
            weeklyBudget: createUserDto.weeklyBudget ?? 0
        });
    }
    async findById(id) {
        const user = await this.userRepository.findById(id);
        if (!user) {
            throw new common_1.NotFoundException(`User with ID ${id} not found`);
        }
        return user;
    }
    async findByEmail(email) {
        return await this.userRepository.findByEmail(email);
    }
    async findAll(skip = 0, take = 10) {
        const [data, total] = await this.userRepository.findAll(skip, take);
        return { data, total };
    }
    async update(id, updateUserDto) {
        const currentUser = await this.findById(id);
        if (updateUserDto.email) {
            const email = this.normalizeEmail(updateUserDto.email);
            const existingUser = await this.userRepository.findByEmail(email);
            if (existingUser && existingUser.id.toHexString() !== id) {
                throw new common_1.BadRequestException("Email already in use");
            }
        }
        const updatedUser = await this.userRepository.update(id, {
            email: updateUserDto.email ? this.normalizeEmail(updateUserDto.email) : undefined,
            name: updateUserDto.name,
            passwordHash: updateUserDto.password ? (0, crypto_util_1.hashPassword)(updateUserDto.password) : currentUser.passwordHash,
            role: updateUserDto.role,
            avatarUrl: updateUserDto.avatarUrl,
            weeklyBudget: updateUserDto.weeklyBudget
        });
        if (!updatedUser) {
            throw new common_1.NotFoundException("Failed to update user");
        }
        return updatedUser;
    }
    async delete(id) {
        await this.findById(id);
        const result = await this.userRepository.delete(id);
        if (!result) {
            throw new common_1.NotFoundException("Failed to delete user");
        }
        return { message: "User deleted successfully" };
    }
    toPublicProfile(user) {
        return (0, user_response_mapper_1.toPublicUserProfile)(user);
    }
};
exports.UserService = UserService;
exports.UserService = UserService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [user_repository_1.UserRepository])
], UserService);
//# sourceMappingURL=user.service.js.map