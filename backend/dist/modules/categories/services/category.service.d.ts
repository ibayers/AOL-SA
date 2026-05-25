import { CategoryRepository } from '../repositories/category.repository';
import { CreateCategoryDto } from '../dto/create-category.dto';
export declare class CategoryService {
    private readonly repo;
    constructor(repo: CategoryRepository);
    findByUserId(userId: string): Promise<import("../entities/category.entity").Category[]>;
    create(userId: string, dto: CreateCategoryDto): Promise<import("../entities/category.entity").Category>;
    update(id: string, dto: CreateCategoryDto): Promise<import("../entities/category.entity").Category>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
