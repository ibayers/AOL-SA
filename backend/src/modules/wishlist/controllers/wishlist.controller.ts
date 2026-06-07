import {
  Controller, Get, Post, Put, Delete, Patch, Body, Param,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '../../auth/guards/auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { WishlistService } from '../services/wishlist.service';
import { CreateWishlistItemDto } from '../dto/create-wishlist-item.dto';

@Controller('wishlist')
@UseGuards(AuthGuard)
export class WishlistController {
  constructor(private readonly service: WishlistService) {}

  @Get()
  async findAll(@CurrentUser('id') userId: string) {
    const items = await this.service.findByUserId(userId);
    return items.map((i) => ({
      id: i.id.toHexString(),
      user_id: i.userId,
      name: i.name,
      price: i.price,
      saved_amount: i.savedAmount || 0,
      status: i.status,
      image_path: i.imagePath,
      created_at: i.createdAt?.toISOString(),
    }));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateWishlistItemDto) {
    const item = await this.service.create(userId, dto);
    return {
      id: item.id.toHexString(),
      name: item.name,
      price: item.price,
      saved_amount: item.savedAmount || 0,
      status: item.status,
      image_path: item.imagePath,
    };
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() dto: CreateWishlistItemDto) {
    const item = await this.service.update(id, dto);
    return {
      id: item.id.toHexString(),
      name: item.name,
      price: item.price,
      saved_amount: item.savedAmount || 0,
      status: item.status,
      image_path: item.imagePath,
    };
  }

  @Patch(':id/complete')
  async markCompleted(@Param('id') id: string) {
    const item = await this.service.markCompleted(id);
    return { id: item.id.toHexString(), status: item.status };
  }

  @Patch(':id/invest')
  async invest(
    @Param('id') id: string,
    @Body() body: { amount: number },
  ) {
    const item = await this.service.invest(id, body.amount);
    return {
      id: item.id.toHexString(),
      name: item.name,
      price: item.price,
      saved_amount: item.savedAmount || 0,
      status: item.status,
    };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async delete(@Param('id') id: string) {
    return await this.service.delete(id);
  }
}
