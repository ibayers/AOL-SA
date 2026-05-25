import { TransactionService } from '../services/transaction.service';
import { CreateTransactionDto } from '../dto/create-transaction.dto';
export declare class TransactionsController {
    private readonly service;
    constructor(service: TransactionService);
    findAll(userId: string, from?: string, to?: string): Promise<{
        id: string;
        user_id: string;
        amount: number;
        type: string;
        category_id: string;
        payment_method_id: string;
        note: string;
        date: string;
        feeling: string;
        created_at: string;
    }[]>;
    create(userId: string, dto: CreateTransactionDto): Promise<{
        id: string;
        amount: number;
        type: string;
        category_id: string;
        payment_method_id: string;
        note: string;
        date: string;
        feeling: string;
    }>;
    update(id: string, dto: CreateTransactionDto): Promise<{
        id: string;
        amount: number;
        type: string;
        category_id: string;
        payment_method_id: string;
        note: string;
        date: string;
        feeling: string;
    }>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
