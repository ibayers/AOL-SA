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
exports.WishlistController = void 0;
const common_1 = require("@nestjs/common");
const auth_guard_1 = require("../../auth/guards/auth.guard");
const current_user_decorator_1 = require("../../auth/decorators/current-user.decorator");
const wishlist_service_1 = require("../services/wishlist.service");
const create_wishlist_item_dto_1 = require("../dto/create-wishlist-item.dto");
let WishlistController = class WishlistController {
    constructor(service) {
        this.service = service;
    }
    async findAll(userId) {
        const items = await this.service.findByUserId(userId);
        return items.map((i) => ({
            id: i.id.toHexString(),
            user_id: i.userId,
            name: i.name,
            price: i.price,
            saved_amount: i.savedAmount || 0,
            status: i.status,
            image_path: i.imagePath,
            created_at: i.createdAt?.toISOString(),
        }));
    }
    async create(userId, dto) {
        const item = await this.service.create(userId, dto);
        return {
            id: item.id.toHexString(),
            name: item.name,
            price: item.price,
            saved_amount: item.savedAmount || 0,
            status: item.status,
            image_path: item.imagePath,
        };
    }
    async update(id, dto) {
        const item = await this.service.update(id, dto);
        return {
            id: item.id.toHexString(),
            name: item.name,
            price: item.price,
            saved_amount: item.savedAmount || 0,
            status: item.status,
            image_path: item.imagePath,
        };
    }
    async markCompleted(id) {
        const item = await this.service.markCompleted(id);
        return { id: item.id.toHexString(), status: item.status };
    }
    async invest(id, body) {
        const item = await this.service.invest(id, body.amount);
        return {
            id: item.id.toHexString(),
            name: item.name,
            price: item.price,
            saved_amount: item.savedAmount || 0,
            status: item.status,
        };
    }
    async delete(id) {
        return await this.service.delete(id);
    }
};
exports.WishlistController = WishlistController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, current_user_decorator_1.CurrentUser)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "findAll", null);
__decorate([
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, current_user_decorator_1.CurrentUser)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_wishlist_item_dto_1.CreateWishlistItemDto]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, create_wishlist_item_dto_1.CreateWishlistItemDto]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "update", null);
__decorate([
    (0, common_1.Patch)(':id/complete'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "markCompleted", null);
__decorate([
    (0, common_1.Patch)(':id/invest'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "invest", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], WishlistController.prototype, "delete", null);
exports.WishlistController = WishlistController = __decorate([
    (0, common_1.Controller)('wishlist'),
    (0, common_1.UseGuards)(auth_guard_1.AuthGuard),
    __metadata("design:paramtypes", [wishlist_service_1.WishlistService])
], WishlistController);
//# sourceMappingURL=wishlist.controller.js.map