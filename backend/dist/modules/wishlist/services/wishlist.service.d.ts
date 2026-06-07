import { WishlistItemRepository } from '../repositories/wishlist-item.repository';
import { CreateWishlistItemDto } from '../dto/create-wishlist-item.dto';
export declare class WishlistService {
    private readonly repo;
    constructor(repo: WishlistItemRepository);
    findByUserId(userId: string): Promise<import("../entities/wishlist-item.entity").WishlistItem[]>;
    create(userId: string, dto: CreateWishlistItemDto): Promise<import("../entities/wishlist-item.entity").WishlistItem>;
    update(id: string, dto: CreateWishlistItemDto): Promise<import("../entities/wishlist-item.entity").WishlistItem>;
    markCompleted(id: string): Promise<import("../entities/wishlist-item.entity").WishlistItem>;
    invest(id: string, amount: number): Promise<import("../entities/wishlist-item.entity").WishlistItem>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
