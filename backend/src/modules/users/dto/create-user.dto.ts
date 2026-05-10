import { IsEmail, IsNotEmpty, MinLength, MaxLength, IsOptional, IsNumber } from "class-validator";
import { Type } from "class-transformer";

export class CreateUserDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(255)
  name: string;

  @IsNotEmpty()
  @MinLength(6)
  password: string;

  @IsOptional()
  role?: string;

  @IsOptional()
  @MaxLength(2048)
  avatarUrl?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  weeklyBudget?: number;
}
