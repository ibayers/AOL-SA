import { WishlistService } from '../services/wishlist.service';
import { CreateWishlistItemDto } from '../dto/create-wishlist-item.dto';
export declare class WishlistController {
    private readonly service;
    constructor(service: WishlistService);
    findAll(userId: string): Promise<{
        id: string;
        user_id: string;
        name: string;
        price: number;
        saved_amount: number;
        status: string;
        image_path: string;
        created_at: string;
    }[]>;
    create(userId: string, dto: CreateWishlistItemDto): Promise<{
        id: string;
        name: string;
        price: number;
        saved_amount: number;
        status: string;
        image_path: string;
    }>;
    update(id: string, dto: CreateWishlistItemDto): Promise<{
        id: string;
        name: string;
        price: number;
        saved_amount: number;
        status: string;
        image_path: string;
    }>;
    markCompleted(id: string): Promise<{
        id: string;
        status: string;
    }>;
    invest(id: string, body: {
        amount: number;
    }): Promise<{
        id: string;
        name: string;
        price: number;
        saved_amount: number;
        status: string;
    }>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
