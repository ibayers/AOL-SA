import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ObjectId } from 'mongodb';
import { WishlistItem } from '../entities/wishlist-item.entity';

@Injectable()
export class WishlistItemRepository {
  constructor(
    @InjectRepository(WishlistItem)
    private readonly repository: Repository<WishlistItem>,
  ) {}

  async findByUserId(userId: string): Promise<WishlistItem[]> {
    return await this.repository.find({ where: { userId } });
  }

  async findById(id: string): Promise<WishlistItem> {
    return await this.repository.findOne({ where: { _id: new ObjectId(id) } } as any);
  }

  async create(data: Partial<WishlistItem>): Promise<WishlistItem> {
    const entity = this.repository.create(data);
    return await this.repository.save(entity);
  }

  async update(id: string, data: Partial<WishlistItem>): Promise<WishlistItem> {
    await this.repository.update({ _id: new ObjectId(id) } as any, data);
    return await this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete({ _id: new ObjectId(id) } as any);
    return result.affected > 0;
  }
}
