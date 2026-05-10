import { Body, Controller, Get, HttpCode, HttpStatus, Post, Req, UseGuards } from "@nestjs/common";
import { Request } from "express";
import { CreateUserDto } from "../../users/dto/create-user.dto";
import { LoginDto } from "../dto/login.dto";
import { AuthService } from "../services/auth.service";
import { AuthGuard } from "../guards/auth.guard";
import { CurrentUser } from "../decorators/current-user.decorator";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register")
  @HttpCode(HttpStatus.CREATED)
  async register(@Body() createUserDto: CreateUserDto, @Req() request: Request) {
    const userAgent = typeof request.headers["user-agent"] === "string" ? request.headers["user-agent"] : null;
    return await this.authService.register(createUserDto, userAgent);
  }

  @Post("login")
  @HttpCode(HttpStatus.OK)
  async login(@Body() loginDto: LoginDto, @Req() request: Request) {
    const userAgent = typeof request.headers["user-agent"] === "string" ? request.headers["user-agent"] : null;
    return await this.authService.login(loginDto, userAgent);
  }

  @Post("logout")
  @UseGuards(AuthGuard)
  @HttpCode(HttpStatus.OK)
  async logout(@Req() request: Request & { accessToken?: string }) {
    return await this.authService.logout(request.accessToken ?? "");
  }

  @Get("me")
  @UseGuards(AuthGuard)
  async me(@CurrentUser() user: unknown) {
    return user;
  }
}