import { IsOptional, IsEmail, MinLength, MaxLength, IsNumber } from "class-validator";
import { Type } from "class-transformer";

export class UpdateUserDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @MinLength(3)
  name?: string;

  @IsOptional()
  @MinLength(6)
  password?: string;

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
