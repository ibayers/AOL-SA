import {
  Controller, Get, Post, Put, Delete, Body, Param, Query,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '../../auth/guards/auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { TransactionService } from '../services/transaction.service';
import { CreateTransactionDto } from '../dto/create-transaction.dto';

@Controller('transactions')
@UseGuards(AuthGuard)
export class TransactionsController {
  constructor(private readonly service: TransactionService) {}

  @Get()
  async findAll(
    @CurrentUser('id') userId: string,
    @Query('from') from?: string,
    @Query('to') to?: string,
  ) {
    const transactions = await this.service.findByUserId(userId, from, to);
    return transactions.map((t) => ({
      id: t.id.toHexString(),
      user_id: t.userId,
      amount: t.amount,
      type: t.type,
      category_id: t.categoryId,
      payment_method_id: t.paymentMethodId,
      note: t.note,
      date: t.date?.toISOString(),
      feeling: t.feeling,
      created_at: t.createdAt?.toISOString(),
    }));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateTransactionDto) {
    const txn = await this.service.create(userId, dto);
    return {
      id: txn.id.toHexString(),
      amount: txn.amount,
      type: txn.type,
      category_id: txn.categoryId,
      payment_method_id: txn.paymentMethodId,
      note: txn.note,
      date: txn.date?.toISOString(),
      feeling: txn.feeling,
    };
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() dto: CreateTransactionDto) {
    const txn = await this.service.update(id, dto);
    return {
      id: txn.id.toHexString(),
      amount: txn.amount,
      type: txn.type,
      category_id: txn.categoryId,
      payment_method_id: txn.paymentMethodId,
      note: txn.note,
      date: txn.date?.toISOString(),
      feeling: txn.feeling,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async delete(@Param('id') id: string) {
    return await this.service.delete(id);
  }
}
