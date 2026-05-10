import { User } from "../entities/user.entity";
export interface PublicUserProfile {
    id: string;
    name: string;
    email: string;
    avatar_url: string | null;
    weekly_budget: number;
    role: string;
    is_active: boolean;
    created_at: string;
    updated_at: string;
}
export declare function toPublicUserProfile(user: User): PublicUserProfile;
