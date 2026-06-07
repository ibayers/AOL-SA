import { ObjectId } from 'mongodb';
export declare class WishlistItem {
    id: ObjectId;
    userId: string;
    name: string;
    price: number;
    savedAmount: number;
    status: string;
    imagePath: string;
    createdAt: Date;
}
