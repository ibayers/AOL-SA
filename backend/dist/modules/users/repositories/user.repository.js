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
exports.UserRepository = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const mongodb_1 = require("mongodb");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("../entities/user.entity");
let UserRepository = class UserRepository {
    constructor(repository) {
        this.repository = repository;
    }
    async create(userData) {
        const user = this.repository.create(userData);
        return await this.repository.save(user);
    }
    async findById(id) {
        return await this.repository.findOne({ where: { _id: new mongodb_1.ObjectId(id) } });
    }
    async findByEmail(email) {
        return await this.repository.findOne({ where: { email } });
    }
    async findAll(skip = 0, take = 10) {
        return await this.repository.findAndCount({ skip, take });
    }
    async update(id, updateData) {
        await this.repository.update({ _id: new mongodb_1.ObjectId(id) }, updateData);
        return await this.findById(id);
    }
    async delete(id) {
        const result = await this.repository.delete({ _id: new mongodb_1.ObjectId(id) });
        return result.affected > 0;
    }
};
exports.UserRepository = UserRepository;
exports.UserRepository = UserRepository = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], UserRepository);
//# sourceMappingURL=user.repository.js.map