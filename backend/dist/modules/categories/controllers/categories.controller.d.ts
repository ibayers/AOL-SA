import { CategoryService } from '../services/category.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
export declare class CategoriesController {
    private readonly service;
    constructor(service: CategoryService);
    findAll(userId: string): Promise<{
        id: string;
        user_id: string;
        name: string;
        icon: string;
        type: string;
        created_at: string;
    }[]>;
    create(userId: string, dto: CreateCategoryDto): Promise<{
        id: string;
        name: string;
        icon: string;
        type: string;
    }>;
    update(id: string, dto: CreateCategoryDto): Promise<{
        id: string;
        name: string;
        icon: string;
        type: string;
    }>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
