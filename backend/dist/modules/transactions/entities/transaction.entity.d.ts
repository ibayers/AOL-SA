import { ObjectId } from 'mongodb';
export declare class Transaction {
    id: ObjectId;
    userId: string;
    amount: number;
    type: string;
    categoryId: string;
    paymentMethodId: string;
    note: string;
    date: Date;
    feeling: string;
    createdAt: Date;
}
