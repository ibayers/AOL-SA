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

export function toPublicUserProfile(user: User): PublicUserProfile {
  return {
    id: user.id?.toHexString?.() ?? String(user.id),
    name: user.name,
    email: user.email,
    avatar_url: user.avatarUrl,
    weekly_budget: user.weeklyBudget ?? 0,
    role: user.role,
    is_active: user.isActive,
    created_at: user.createdAt?.toISOString(),
    updated_at: user.updatedAt?.toISOString()
  };
}