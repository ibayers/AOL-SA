"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toPublicUserProfile = toPublicUserProfile;
function toPublicUserProfile(user) {
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
//# sourceMappingURL=user-response.mapper.js.map