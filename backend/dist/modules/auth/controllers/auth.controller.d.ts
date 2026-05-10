import { Request } from "express";
import { CreateUserDto } from "../../users/dto/create-user.dto";
import { LoginDto } from "../dto/login.dto";
import { AuthService } from "../services/auth.service";
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    register(createUserDto: CreateUserDto, request: Request): Promise<import("../services/auth.service").AuthResponse>;
    login(loginDto: LoginDto, request: Request): Promise<import("../services/auth.service").AuthResponse>;
    logout(request: Request & {
        accessToken?: string;
    }): Promise<{
        message: string;
    }>;
    me(user: unknown): Promise<unknown>;
}
