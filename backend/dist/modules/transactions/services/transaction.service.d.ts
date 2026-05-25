import { TransactionRepository } from '../repositories/transaction.repository';
import { CreateTransactionDto } from '../dto/create-transaction.dto';
export declare class TransactionService {
    private readonly repo;
    constructor(repo: TransactionRepository);
    findByUserId(userId: string, from?: string, to?: string): Promise<import("../entities/transaction.entity").Transaction[]>;
    create(userId: string, dto: CreateTransactionDto): Promise<import("../entities/transaction.entity").Transaction>;
    update(id: string, dto: CreateTransactionDto): Promise<import("../entities/transaction.entity").Transaction>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
