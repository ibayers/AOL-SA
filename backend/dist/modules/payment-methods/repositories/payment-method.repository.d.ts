import { Repository } from 'typeorm';
import { PaymentMethod } from '../entities/payment-method.entity';
export declare class PaymentMethodRepository {
    private readonly repository;
    constructor(repository: Repository<PaymentMethod>);
    findByUserId(userId: string): Promise<PaymentMethod[]>;
    findById(id: string): Promise<PaymentMethod>;
    create(data: Partial<PaymentMethod>): Promise<PaymentMethod>;
    delete(id: string): Promise<boolean>;
}
