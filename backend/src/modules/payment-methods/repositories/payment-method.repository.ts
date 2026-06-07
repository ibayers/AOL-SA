import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ObjectId } from 'mongodb';
import { PaymentMethod } from '../entities/payment-method.entity';

@Injectable()
export class PaymentMethodRepository {
  constructor(
    @InjectRepository(PaymentMethod)
    private readonly repository: Repository<PaymentMethod>,
  ) {}

  async findByUserId(userId: string): Promise<PaymentMethod[]> {
    return await this.repository.find({ where: { userId } });
  }

  async findById(id: string): Promise<PaymentMethod> {
    return await this.repository.findOne({ where: { _id: new ObjectId(id) } } as any);
  }

  async create(data: Partial<PaymentMethod>): Promise<PaymentMethod> {
    const entity = this.repository.create(data);
    return await this.repository.save(entity);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete(id as any);
    return result.affected > 0;
  }
}
