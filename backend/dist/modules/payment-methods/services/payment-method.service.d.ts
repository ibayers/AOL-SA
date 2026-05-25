import { PaymentMethodRepository } from '../repositories/payment-method.repository';
import { CreatePaymentMethodDto } from '../dto/create-payment-method.dto';
export declare class PaymentMethodService {
    private readonly repo;
    constructor(repo: PaymentMethodRepository);
    findByUserId(userId: string): Promise<import("../entities/payment-method.entity").PaymentMethod[]>;
    create(userId: string, dto: CreatePaymentMethodDto): Promise<import("../entities/payment-method.entity").PaymentMethod>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
