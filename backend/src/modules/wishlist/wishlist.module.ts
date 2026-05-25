import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WishlistItem } from './entities/wishlist-item.entity';
import { WishlistController } from './controllers/wishlist.controller';
import { WishlistService } from './services/wishlist.service';
import { WishlistItemRepository } from './repositories/wishlist-item.repository';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([WishlistItem]), AuthModule],
  controllers: [WishlistController],
  providers: [WishlistService, WishlistItemRepository],
})
export class WishlistModule {}
