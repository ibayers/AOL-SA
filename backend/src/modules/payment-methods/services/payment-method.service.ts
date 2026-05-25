import { Injectable, NotFoundException } from '@nestjs/common';
import { PaymentMethodRepository } from '../repositories/payment-method.repository';
import { CreatePaymentMethodDto } from '../dto/create-payment-method.dto';

@Injectable()
export class PaymentMethodService {
  constructor(private readonly repo: PaymentMethodRepository) {}

  async findByUserId(userId: string) {
    return await this.repo.findByUserId(userId);
  }

  async create(userId: string, dto: CreatePaymentMethodDto) {
    return await this.repo.create({
      userId,
      name: dto.name,
    });
  }

  async delete(id: string) {
    const result = await this.repo.delete(id);
    if (!result) throw new NotFoundException('Payment method not found');
    return { message: 'Payment method deleted' };
  }
}
