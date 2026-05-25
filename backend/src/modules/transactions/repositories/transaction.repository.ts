import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ObjectId } from 'mongodb';
import { Transaction } from '../entities/transaction.entity';

@Injectable()
export class TransactionRepository {
  constructor(
    @InjectRepository(Transaction)
    private readonly repository: Repository<Transaction>,
  ) {}

  async findByUserId(userId: string, from?: Date, to?: Date): Promise<Transaction[]> {
    const where: any = { userId };
    if (from || to) {
      where.date = {};
      if (from) where.date.$gte = from;
      if (to) where.date.$lte = to;
    }
    return await this.repository.find({ where, order: { date: 'DESC' } });
  }

  async findById(id: string): Promise<Transaction> {
    return await this.repository.findOne({ where: { _id: new ObjectId(id) } } as any);
  }

  async create(data: Partial<Transaction>): Promise<Transaction> {
    const entity = this.repository.create(data);
    return await this.repository.save(entity);
  }

  async update(id: string, data: Partial<Transaction>): Promise<Transaction> {
    await this.repository.update({ _id: new ObjectId(id) } as any, data);
    return await this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete({ _id: new ObjectId(id) } as any);
    return result.affected > 0;
  }
}
