import { Injectable, NotFoundException } from '@nestjs/common';
import { WishlistItemRepository } from '../repositories/wishlist-item.repository';
import { CreateWishlistItemDto } from '../dto/create-wishlist-item.dto';

@Injectable()
export class WishlistService {
  constructor(private readonly repo: WishlistItemRepository) {}

  async findByUserId(userId: string) {
    return await this.repo.findByUserId(userId);
  }

  async create(userId: string, dto: CreateWishlistItemDto) {
    return await this.repo.create({
      userId,
      name: dto.name,
      price: dto.price,
      status: dto.status ?? 'pending',
      imagePath: dto.imagePath,
    });
  }

  async update(id: string, dto: CreateWishlistItemDto) {
    const item = await this.repo.findById(id);
    if (!item) throw new NotFoundException('Wishlist item not found');
    return await this.repo.update(id, {
      name: dto.name,
      price: dto.price,
      status: dto.status,
      imagePath: dto.imagePath,
    });
  }

  async markCompleted(id: string) {
    const item = await this.repo.findById(id);
    if (!item) throw new NotFoundException('Wishlist item not found');
    return await this.repo.update(id, { status: 'completed' });
  }

  async delete(id: string) {
    const result = await this.repo.delete(id);
    if (!result) throw new NotFoundException('Wishlist item not found');
    return { message: 'Wishlist item deleted' };
  }
}
