import { ObjectId } from "mongodb";
export declare class User {
    id: ObjectId;
    email: string;
    name: string;
    passwordHash: string;
    avatarUrl: string | null;
    weeklyBudget: number;
    role: string;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
