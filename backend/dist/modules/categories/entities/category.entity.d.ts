import { ObjectId } from 'mongodb';
export declare class Category {
    id: ObjectId;
    userId: string;
    name: string;
    icon: string;
    type: string;
    createdAt: Date;
}
