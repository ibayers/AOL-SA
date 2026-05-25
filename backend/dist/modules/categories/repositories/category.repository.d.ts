import { Repository } from 'typeorm';
import { Category } from '../entities/category.entity';
export declare class CategoryRepository {
    private readonly repository;
    constructor(repository: Repository<Category>);
    findByUserId(userId: string): Promise<Category[]>;
    findById(id: string): Promise<Category>;
    create(data: Partial<Category>): Promise<Category>;
    update(id: string, data: Partial<Category>): Promise<Category>;
    delete(id: string): Promise<boolean>;
}
