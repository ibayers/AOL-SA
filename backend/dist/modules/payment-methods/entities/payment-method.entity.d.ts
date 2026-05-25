import { ObjectId } from 'mongodb';
export declare class PaymentMethod {
    id: ObjectId;
    userId: string;
    name: string;
    createdAt: Date;
}
