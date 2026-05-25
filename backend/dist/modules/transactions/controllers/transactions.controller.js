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
exports.TransactionsController = void 0;
const common_1 = require("@nestjs/common");
const auth_guard_1 = require("../../auth/guards/auth.guard");
const current_user_decorator_1 = require("../../auth/decorators/current-user.decorator");
const transaction_service_1 = require("../services/transaction.service");
const create_transaction_dto_1 = require("../dto/create-transaction.dto");
let TransactionsController = class TransactionsController {
    constructor(service) {
        this.service = service;
    }
    async findAll(userId, from, to) {
        const transactions = await this.service.findByUserId(userId, from, to);
        return transactions.map((t) => ({
            id: t.id.toHexString(),
            user_id: t.userId,
            amount: t.amount,
            type: t.type,
            category_id: t.categoryId,
            payment_method_id: t.paymentMethodId,
            note: t.note,
            date: t.date?.toISOString(),
            feeling: t.feeling,
            created_at: t.createdAt?.toISOString(),
        }));
    }
    async create(userId, dto) {
        const txn = await this.service.create(userId, dto);
        return {
            id: txn.id.toHexString(),
            amount: txn.amount,
            type: txn.type,
            category_id: txn.categoryId,
            payment_method_id: txn.paymentMethodId,
            note: txn.note,
            date: txn.date?.toISOString(),
            feeling: txn.feeling,
        };
    }
    async update(id, dto) {
        const txn = await this.service.update(id, dto);
        return {
            id: txn.id.toHexString(),
            amount: txn.amount,
            type: txn.type,
            category_id: txn.categoryId,
            payment_method_id: txn.paymentMethodId,
            note: txn.note,
            date: txn.date?.toISOString(),
            feeling: txn.feeling,
        };
    }
    async delete(id) {
        return await this.service.delete(id);
    }
};
exports.TransactionsController = TransactionsController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)('id')),
    __param(1, (0, common_1.Query)('from')),
    __param(2, (0, common_1.Query)('to')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, String, String]),
    __metadata("design:returntype", Promise)
], TransactionsController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, current_user_decorator_1.CurrentUser)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_transaction_dto_1.CreateTransactionDto]),
    __metadata("design:returntype", Promise)
], TransactionsController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_transaction_dto_1.CreateTransactionDto]),
    __metadata("design:returntype", Promise)
], TransactionsController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], TransactionsController.prototype, "delete", null);
exports.TransactionsController = TransactionsController = __decorate([
    (0, common_1.Controller)('transactions'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    __metadata("design:paramtypes", [transaction_service_1.TransactionService])
], TransactionsController);
//# sourceMappingURL=transactions.controller.js.map