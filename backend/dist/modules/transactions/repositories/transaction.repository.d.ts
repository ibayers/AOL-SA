import { Repository } from 'typeorm';
import { Transaction } from '../entities/transaction.entity';
export declare class TransactionRepository {
    private readonly repository;
    constructor(repository: Repository<Transaction>);
    findByUserId(userId: string, from?: Date, to?: Date): Promise<Transaction[]>;
    findById(id: string): Promise<Transaction>;
    create(data: Partial<Transaction>): Promise<Transaction>;
    update(id: string, data: Partial<Transaction>): Promise<Transaction>;
    delete(id: string): Promise<boolean>;
}
