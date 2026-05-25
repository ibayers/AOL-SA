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
exports.CategoryService = void 0;
const common_1 = require("@nestjs/common");
const category_repository_1 = require("../repositories/category.repository");
let CategoryService = class CategoryService {
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
            icon: dto.icon ?? '📂',
            type: dto.type ?? 'expense',
        });
    }
    async update(id, dto) {
        const cat = await this.repo.findById(id);
        if (!cat)
            throw new common_1.NotFoundException('Category not found');
        return await this.repo.update(id, { name: dto.name, icon: dto.icon, type: dto.type });
    }
    async delete(id) {
        const result = await this.repo.delete(id);
        if (!result)
            throw new common_1.NotFoundException('Category not found');
        return { message: 'Category deleted' };
    }
};
exports.CategoryService = CategoryService;
exports.CategoryService = CategoryService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [category_repository_1.CategoryRepository])
], CategoryService);
//# sourceMappingURL=category.service.js.map