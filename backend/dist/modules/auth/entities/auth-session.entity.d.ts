import { ObjectId } from "mongodb";
export declare class AuthSession {
    id: ObjectId;
    tokenHash: string;
    userId: ObjectId;
    userAgent: string | null;
    expiresAt: Date;
    revokedAt: Date | null;
    createdAt: Date;
}
