import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ObjectId } from 'mongodb';
import { Category } from '../entities/category.entity';

@Injectable()
export class CategoryRepository {
  constructor(
    @InjectRepository(Category)
    private readonly repository: Repository<Category>,
  ) {}

  async findByUserId(userId: string): Promise<Category[]> {
    return await this.repository.find({ where: { userId } });
  }

  async findById(id: string): Promise<Category> {
    return await this.repository.findOne({ where: { _id: new ObjectId(id) } } as any);
  }

  async create(data: Partial<Category>): Promise<Category> {
    const entity = this.repository.create(data);
    return await this.repository.save(entity);
  }

  async update(id: string, data: Partial<Category>): Promise<Category> {
    await this.repository.update(id as any, data);
    return await this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete(id as any);
    return result.affected > 0;
  }
}
