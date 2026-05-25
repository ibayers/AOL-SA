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
exports.TransactionRepository = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const mongodb_1 = require("mongodb");
const transaction_entity_1 = require("../entities/transaction.entity");
let TransactionRepository = class TransactionRepository {
    constructor(repository) {
        this.repository = repository;
    }
    async findByUserId(userId, from, to) {
        const where = { userId };
        if (from || to) {
            where.date = {};
            if (from)
                where.date.$gte = from;
            if (to)
                where.date.$lte = to;
        }
        return await this.repository.find({ where, order: { date: 'DESC' } });
    }
    async findById(id) {
        return await this.repository.findOne({ where: { _id: new mongodb_1.ObjectId(id) } });
    }
    async create(data) {
        const entity = this.repository.create(data);
        return await this.repository.save(entity);
    }
    async update(id, data) {
        await this.repository.update({ _id: new mongodb_1.ObjectId(id) }, data);
        return await this.findById(id);
    }
    async delete(id) {
        const result = await this.repository.delete({ _id: new mongodb_1.ObjectId(id) });
        return result.affected > 0;
    }
};
exports.TransactionRepository = TransactionRepository;
exports.TransactionRepository = TransactionRepository = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(transaction_entity_1.Transaction)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], TransactionRepository);
//# sourceMappingURL=transaction.repository.js.map