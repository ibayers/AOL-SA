import {
  Controller, Get, Post, Put, Delete, Body, Param,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '../../auth/guards/auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { CategoryService } from '../services/category.service';
import { CreateCategoryDto } from '../dto/create-category.dto';

@Controller('categories')
@UseGuards(AuthGuard)
export class CategoriesController {
  constructor(private readonly service: CategoryService) {}

  @Get()
  async findAll(@CurrentUser('id') userId: string) {
    const categories = await this.service.findByUserId(userId);
    return categories.map((c) => ({
      id: c.id.toHexString(),
      user_id: c.userId,
      name: c.name,
      icon: c.icon,
      type: c.type,
      created_at: c.createdAt?.toISOString(),
    }));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@CurrentUser('id') userId: string, @Body() dto: CreateCategoryDto) {
    const cat = await this.service.create(userId, dto);
    return { id: cat.id.toHexString(), name: cat.name, icon: cat.icon, type: cat.type };
  }

  @Put(':id')
  async update(@Param('id') id: string, @Body() dto: CreateCategoryDto) {
    const cat = await this.service.update(id, dto);
    return { id: cat.id.toHexString(), name: cat.name, icon: cat.icon, type: cat.type };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async delete(@Param('id') id: string) {
    return await this.service.delete(id);
  }
}
