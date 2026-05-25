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
exports.PaymentMethodService = void 0;
const common_1 = require("@nestjs/common");
const payment_method_repository_1 = require("../repositories/payment-method.repository");
let PaymentMethodService = class PaymentMethodService {
    constructor(repo) {
        this.repo = repo;
    }
    async findByUserId(userId) {
        return await this.repo.findByUserId(userId);
    }
    async create(userId, dto) {
        return await this.repo.create({
            userId,
            name: dto.name,
        });
    }
    async delete(id) {
        const result = await this.repo.delete(id);
        if (!result)
            throw new common_1.NotFoundException('Payment method not found');
        return { message: 'Payment method deleted' };
    }
};
exports.PaymentMethodService = PaymentMethodService;
exports.PaymentMethodService = PaymentMethodService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [payment_method_repository_1.PaymentMethodRepository])
], PaymentMethodService);
//# sourceMappingURL=payment-method.service.js.map