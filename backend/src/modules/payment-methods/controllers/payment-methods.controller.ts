import {
  Controller, Get, Post, Delete, Body, Param,
  UseGuards, HttpCode, HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '../../auth/guards/auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { PaymentMethodService } from '../services/payment-method.service';
import { CreatePaymentMethodDto } from '../dto/create-payment-method.dto';

@Controller('payment-methods')
@UseGuards(AuthGuard)
export class PaymentMethodsController {
  constructor(private readonly service: PaymentMethodService) {}

  @Get()
  async findAll(@CurrentUser('id') userId: string) {
    const methods = await this.service.findByUserId(userId);
    return methods.map((m) => ({
      id: m.id.toHexString(),
      user_id: m.userId,
      name: m.name,
      created_at: m.createdAt?.toISOString(),
    }));
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@CurrentUser('id') userId: string, @Body() dto: CreatePaymentMethodDto) {
    const method = await this.service.create(userId, dto);
    return { id: method.id.toHexString(), name: method.name };
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  async delete(@Param('id') id: string) {
    return await this.service.delete(id);
  }
}
