import { Injectable, NotFoundException } from '@nestjs/common';
import { TransactionRepository } from '../repositories/transaction.repository';
import { CreateTransactionDto } from '../dto/create-transaction.dto';

@Injectable()
export class TransactionService {
  constructor(private readonly repo: TransactionRepository) {}

  async findByUserId(userId: string, from?: string, to?: string) {
    const fromDate = from ? new Date(from) : undefined;
    const toDate = to ? new Date(to) : undefined;
    return await this.repo.findByUserId(userId, fromDate, toDate);
  }

  async create(userId: string, dto: CreateTransactionDto) {
    return await this.repo.create({
      userId,
      amount: dto.amount,
      type: dto.type,
      categoryId: dto.categoryId,
      paymentMethodId: dto.paymentMethodId,
      note: dto.note,
      date: new Date(dto.date),
      feeling: dto.feeling,
    });
  }

  async update(id: string, dto: CreateTransactionDto) {
    const txn = await this.repo.findById(id);
    if (!txn) throw new NotFoundException('Transaction not found');
    return await this.repo.update(id, {
      amount: dto.amount,
      type: dto.type,
      categoryId: dto.categoryId,
      paymentMethodId: dto.paymentMethodId,
      note: dto.note,
      date: dto.date ? new Date(dto.date) : undefined,
      feeling: dto.feeling,
    });
  }

  async delete(id: string) {
    const result = await this.repo.delete(id);
    if (!result) throw new NotFoundException('Transaction not found');
    return { message: 'Transaction deleted' };
  }
}
