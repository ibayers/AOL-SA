import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { UsersModule } from "../users/users.module";
import { AuthSession } from "./entities/auth-session.entity";
import { AuthController } from "./controllers/auth.controller";
import { AuthService } from "./services/auth.service";
import { AuthSessionRepository } from "./repositories/auth-session.repository";
import { AuthGuard } from "./guards/auth.guard";

@Module({
  imports: [ConfigModule, UsersModule, TypeOrmModule.forFeature([AuthSession])],
  controllers: [AuthController],
  providers: [AuthService, AuthSessionRepository, AuthGuard],
  exports: [AuthService, AuthGuard]
})
export class AuthModule {}