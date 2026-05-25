import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { TypeOrmModule } from "@nestjs/typeorm";
import { AppController } from "./app.controller";
import { AppService } from "./app.service";
import { UsersModule } from "./modules/users/users.module";
import { AuthModule } from "./modules/auth/auth.module";
import { HomeModule } from "./modules/home/home.module";
import { ProfileModule } from "./modules/profile/profile.module";
import { CategoriesModule } from "./modules/categories/categories.module";
import { PaymentMethodsModule } from "./modules/payment-methods/payment-methods.module";
import { TransactionsModule } from "./modules/transactions/transactions.module";
import { WishlistModule } from "./modules/wishlist/wishlist.module";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: ".env" }),
    TypeOrmModule.forRoot({
      type: "mongodb",
      url: process.env.MONGODB_URI || "mongodb://localhost:27017/moni_db",
      autoLoadEntities: true,
      synchronize: false,
      logging: true
    }),
    UsersModule,
    AuthModule,
    HomeModule,
    ProfileModule,
    CategoriesModule,
    PaymentMethodsModule,
    TransactionsModule,
    WishlistModule
  ],
  controllers: [AppController],
  providers: [AppService]
})
export class AppModule {}
