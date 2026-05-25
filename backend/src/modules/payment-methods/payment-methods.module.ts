import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentMethod } from './entities/payment-method.entity';
import { PaymentMethodsController } from './controllers/payment-methods.controller';
import { PaymentMethodService } from './services/payment-method.service';
import { PaymentMethodRepository } from './repositories/payment-method.repository';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([PaymentMethod]), AuthModule],
  controllers: [PaymentMethodsController],
  providers: [PaymentMethodService, PaymentMethodRepository],
})
export class PaymentMethodsModule {}
