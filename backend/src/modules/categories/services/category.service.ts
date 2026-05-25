import { Injectable, NotFoundException } from '@nestjs/common';
import { CategoryRepository } from '../repositories/category.repository';
import { CreateCategoryDto } from '../dto/create-category.dto';

@Injectable()
export class CategoryService {
  constructor(private readonly repo: CategoryRepository) {}

  async findByUserId(userId: string) {
    return await this.repo.findByUserId(userId);
  }

  async create(userId: string, dto: CreateCategoryDto) {
    return await this.repo.create({
      userId,
      name: dto.name,
      icon: dto.icon ?? '📂',
      type: dto.type ?? 'expense',
    });
  }

  async update(id: string, dto: CreateCategoryDto) {
    const cat = await this.repo.findById(id);
    if (!cat) throw new NotFoundException('Category not found');
    return await this.repo.update(id, { name: dto.name, icon: dto.icon, type: dto.type });
  }

  async delete(id: string) {
    const result = await this.repo.delete(id);
    if (!result) throw new NotFoundException('Category not found');
    return { message: 'Category deleted' };
  }
}
