import { PaymentMethodService } from '../services/payment-method.service';
import { CreatePaymentMethodDto } from '../dto/create-payment-method.dto';
export declare class PaymentMethodsController {
    private readonly service;
    constructor(service: PaymentMethodService);
    findAll(userId: string): Promise<{
        id: string;
        user_id: string;
        name: string;
        created_at: string;
    }[]>;
    create(userId: string, dto: CreatePaymentMethodDto): Promise<{
        id: string;
        name: string;
    }>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
