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
exports.TransactionService = void 0;
const common_1 = require("@nestjs/common");
const transaction_repository_1 = require("../repositories/transaction.repository");
let TransactionService = class TransactionService {
    constructor(repo) {
        this.repo = repo;
    }
    async findByUserId(userId, from, to) {
        const fromDate = from ? new Date(from) : undefined;
        const toDate = to ? new Date(to) : undefined;
        return await this.repo.findByUserId(userId, fromDate, toDate);
    }
    async create(userId, dto) {
        return await this.repo.create({
            userId,
            amount: dto.amount,
            type: dto.type,
            categoryId: dto.categoryId,
            paymentMethodId: dto.paymentMethodId,
            note: dto.note,
            date: new Date(dto.date),
            feeling: dto.feeling,
        });
    }
    async update(id, dto) {
        const txn = await this.repo.findById(id);
        if (!txn)
            throw new common_1.NotFoundException('Transaction not found');
        return await this.repo.update(id, {
            amount: dto.amount,
            type: dto.type,
            categoryId: dto.categoryId,
            paymentMethodId: dto.paymentMethodId,
            note: dto.note,
            date: dto.date ? new Date(dto.date) : undefined,
            feeling: dto.feeling,
        });
    }
    async delete(id) {
        const result = await this.repo.delete(id);
        if (!result)
            throw new common_1.NotFoundException('Transaction not found');
        return { message: 'Transaction deleted' };
    }
};
exports.TransactionService = TransactionService;
exports.TransactionService = TransactionService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [transaction_repository_1.TransactionRepository])
], TransactionService);
//# sourceMappingURL=transaction.service.js.map