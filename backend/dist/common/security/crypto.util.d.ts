export declare function hashPassword(password: string): string;
export declare function verifyPassword(password: string, passwordHash: string): boolean;
export declare function generateSessionToken(): string;
export declare function hashToken(token: string): string;
export declare function addHours(date: Date, hours: number): Date;
