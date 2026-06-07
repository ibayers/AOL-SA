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
exports.WishlistService = void 0;
const common_1 = require("@nestjs/common");
const wishlist_item_repository_1 = require("../repositories/wishlist-item.repository");
let WishlistService = class WishlistService {
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
            price: dto.price,
            status: dto.status ?? 'pending',
            imagePath: dto.imagePath,
        });
    }
    async update(id, dto) {
        const item = await this.repo.findById(id);
        if (!item)
            throw new common_1.NotFoundException('Wishlist item not found');
        return await this.repo.update(id, {
            name: dto.name,
            price: dto.price,
            status: dto.status,
            imagePath: dto.imagePath,
        });
    }
    async markCompleted(id) {
        const item = await this.repo.findById(id);
        if (!item)
            throw new common_1.NotFoundException('Wishlist item not found');
        return await this.repo.update(id, { status: 'completed' });
    }
    async invest(id, amount) {
        const item = await this.repo.findById(id);
        if (!item)
            throw new common_1.NotFoundException('Wishlist item not found');
        const newSavedAmount = (item.savedAmount || 0) + amount;
        return await this.repo.update(id, {
            savedAmount: newSavedAmount,
            status: newSavedAmount >= item.price ? 'completed' : 'pending',
        });
    }
    async delete(id) {
        const result = await this.repo.delete(id);
        if (!result)
            throw new common_1.NotFoundException('Wishlist item not found');
        return { message: 'Wishlist item deleted' };
    }
};
exports.WishlistService = WishlistService;
exports.WishlistService = WishlistService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [wishlist_item_repository_1.WishlistItemRepository])
], WishlistService);
//# sourceMappingURL=wishlist.service.js.map