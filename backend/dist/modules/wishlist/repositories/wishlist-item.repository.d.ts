import { Repository } from 'typeorm';
import { WishlistItem } from '../entities/wishlist-item.entity';
export declare class WishlistItemRepository {
    private readonly repository;
    constructor(repository: Repository<WishlistItem>);
    findByUserId(userId: string): Promise<WishlistItem[]>;
    findById(id: string): Promise<WishlistItem>;
    create(data: Partial<WishlistItem>): Promise<WishlistItem>;
    update(id: string, data: Partial<WishlistItem>): Promise<WishlistItem>;
    delete(id: string): Promise<boolean>;
}
