# BE Modules + FE-BE Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create missing backend modules (Transaction, Category, PaymentMethod, Wishlist) and connect the Flutter frontend to the NestJS backend via Dio HTTP client, replacing all dummy data with real API calls.

**Architecture:** NestJS backend with TypeORM + MongoDB (Atlas). Flutter frontend with Riverpod state management and Dio HTTP client. Repository pattern on both sides - abstract interfaces in FE domain layer, Dio-based implementations in FE data layer. Auth token stored in SharedPreferences and sent via Dio interceptor.

**Tech Stack:** NestJS 9, TypeORM, MongoDB Atlas, Flutter, Riverpod, Dio, SharedPreferences

---

## File Structure

### Backend (new files - reverse-engineered from compiled JS + new modules)

```
backend/src/
├── main.ts
├── app.module.ts
├── app.controller.ts
├── app.service.ts
├── common/
│   ├── filters/http-exception.filter.ts
│   └── security/crypto.util.ts
├── modules/
│   ├── auth/             (restored from JS)
│   ├── users/            (restored from JS)
│   ├── home/             (restored from JS)
│   ├── profile/          (restored from JS)
│   ├── transactions/     ← NEW
│   ├── categories/       ← NEW
│   ├── payment-methods/  ← NEW
│   └── wishlist/         ← NEW
```

### Frontend (modified/new files)

```
lib/
├── core/
│   ├── config/api_config.dart          ← NEW
│   └── network/
│       ├── dio_client.dart             ← NEW
│       └── auth_interceptor.dart       ← NEW
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart        ← NEW
│   │   ├── transaction_remote_data_source.dart ← NEW
│   │   ├── category_remote_data_source.dart    ← NEW
│   │   ├── payment_method_remote_data_source.dart ← NEW
│   │   ├── wishlist_remote_data_source.dart    ← NEW
│   │   └── profile_remote_data_source.dart     ← NEW
│   └── repositories/
│       └── repository_impl.dart       ← MODIFY (dummy → API)
└── presentation/screens/auth/
    ├── login_screen.dart              ← MODIFY (call API)
    └── sign_up_screen.dart            ← MODIFY (call API)
```

---

## Task 1: Restore Backend Source Code from Compiled JS

**Files:**
- Create: `backend/src/main.ts`
- Create: `backend/src/app.module.ts`
- Create: `backend/src/app.controller.ts`
- Create: `backend/src/app.service.ts`
- Create: `backend/src/common/filters/http-exception.filter.ts`
- Create: `backend/src/common/security/crypto.util.ts`
- Create: `backend/tsconfig.json`
- Create: `backend/nest-cli.json`

- [ ] **Step 1: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "module": "commonjs",
    "declaration": true,
    "removeComments": true,
    "emitDecoratorMetadata": true,
    "experimentalDecorators": true,
    "allowSyntheticDefaultImports": true,
    "target": "ES2021",
    "sourceMap": true,
    "outDir": "./dist",
    "baseUrl": "./",
    "incremental": true,
    "skipLibCheck": true,
    "strictNullChecks": false,
    "noImplicitAny": false,
    "strictBindCallApply": false,
    "forceConsistentCasingInFileNames": false,
    "noFallthroughCasesInSwitch": false
  }
}
```

- [ ] **Step 2: Create nest-cli.json**

```json
{
  "$schema": "https://json.schemastore.org/nest-cli",
  "collection": "@nestjs/schematics",
  "sourceRoot": "src",
  "compilerOptions": {
    "deleteOutDir": true
  }
}
```

- [ ] **Step 3: Create `backend/src/main.ts`**

```typescript
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: '*', credentials: true });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  app.useGlobalFilters(new HttpExceptionFilter());
  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`Running on http://localhost:${port}`);
}
bootstrap();
```

- [ ] **Step 4: Create `backend/src/common/filters/http-exception.filter.ts`**

```typescript
import {
  ExceptionFilter,
  Catch,
  HttpException,
  ArgumentsHost,
} from '@nestjs/common';
import { Response } from 'express';

@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const status = exception.getStatus();
    const exceptionResponse = exception.getResponse();
    const message =
      typeof exceptionResponse === 'string'
        ? exceptionResponse
        : (exceptionResponse as any).message;

    response.status(status).json({
      statusCode: status,
      message: message || 'Internal Server Error',
      timestamp: new Date().toISOString(),
    });
  }
}
```

- [ ] **Step 5: Create `backend/src/common/security/crypto.util.ts`**

```typescript
import * as crypto from 'crypto';

const PASSWORD_ITERATIONS = 120000;
const PASSWORD_KEY_LENGTH = 64;
const PASSWORD_DIGEST = 'sha512';

export function hashPassword(password: string): string {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto
    .pbkdf2Sync(password, salt, PASSWORD_ITERATIONS, PASSWORD_KEY_LENGTH, PASSWORD_DIGEST)
    .toString('hex');
  return `${salt}:${hash}`;
}

export function verifyPassword(password: string, passwordHash: string): boolean {
  const [salt, storedHash] = passwordHash.split(':');
  if (!salt || !storedHash) return false;
  const computedHash = crypto
    .pbkdf2Sync(password, salt, PASSWORD_ITERATIONS, PASSWORD_KEY_LENGTH, PASSWORD_DIGEST)
    .toString('hex');
  const computedBuffer = Buffer.from(computedHash, 'hex');
  const storedBuffer = Buffer.from(storedHash, 'hex');
  if (computedBuffer.length !== storedBuffer.length) return false;
  return crypto.timingSafeEqual(computedBuffer, storedBuffer);
}

export function generateSessionToken(): string {
  return crypto.randomBytes(32).toString('hex');
}

export function hashToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}

export function addHours(date: Date, hours: number): Date {
  return new Date(date.getTime() + hours * 60 * 60 * 1000);
}
```

- [ ] **Step 6: Create app.service.ts and app.controller.ts**

```typescript
// app.service.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Smart Money API is running!';
  }
}
```

```typescript
// app.controller.ts
import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
```

- [ ] **Step 7: Commit**

```bash
git add backend/src/main.ts backend/src/app.service.ts backend/src/app.controller.ts backend/src/common/ backend/tsconfig.json backend/nest-cli.json
git commit -m "feat(be): restore backend core source files from compiled JS"
```

---

## Task 2: Restore Users Module Source

**Files:**
- Create: `backend/src/modules/users/entities/user.entity.ts`
- Create: `backend/src/modules/users/dto/create-user.dto.ts`
- Create: `backend/src/modules/users/dto/update-user.dto.ts`
- Create: `backend/src/modules/users/mappers/user-response.mapper.ts`
- Create: `backend/src/modules/users/repositories/user.repository.ts`
- Create: `backend/src/modules/users/services/user.service.ts`
- Create: `backend/src/modules/users/controllers/user.controller.ts`
- Create: `backend/src/modules/users/users.module.ts`

- [ ] **Step 1: Create user.entity.ts**

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('users')
export class User {
  @ObjectIdColumn()
  id: ObjectId;

  @Column({ unique: true })
  email: string;

  @Column()
  name: string;

  @Column()
  passwordHash: string;

  @Column({ type: 'varchar', nullable: true })
  avatarUrl: string;

  @Column({ type: 'double precision', default: 0 })
  weeklyBudget: number;

  @Column({ default: 'user' })
  role: string;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn({ type: Date })
  createdAt: Date;

  @UpdateDateColumn({ type: Date })
  updatedAt: Date;
}
```

- [ ] **Step 2: Create DTOs**

```typescript
// create-user.dto.ts
import { IsEmail, IsNotEmpty, IsOptional, MinLength, MaxLength, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';

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
```

```typescript
// update-user.dto.ts
import { IsEmail, IsOptional, MinLength, MaxLength, IsNumber } from 'class-validator';
import { Type } from 'class-transformer';

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
```

- [ ] **Step 3: Create user-response.mapper.ts**

```typescript
import { User } from '../entities/user.entity';

export function toPublicUserProfile(user: User) {
  return {
    id: user.id?.toHexString?.() ?? String(user.id),
    name: user.name,
    email: user.email,
    avatar_url: user.avatarUrl,
    weekly_budget: user.weeklyBudget ?? 0,
    role: user.role,
    is_active: user.isActive,
    created_at: user.createdAt?.toISOString(),
    updated_at: user.updatedAt?.toISOString(),
  };
}
```

- [ ] **Step 4: Create user.repository.ts, user.service.ts, user.controller.ts, users.module.ts**

Port each from the compiled JS already read. Follow the exact same logic from `backend/dist/modules/users/` files.

- [ ] **Step 5: Commit**

```bash
git add backend/src/modules/users/
git commit -m "feat(be): restore users module source from compiled JS"
```

---

## Task 3: Restore Auth + Home + Profile Modules + app.module

**Files:**
- Create: `backend/src/modules/auth/` (all 8 files)
- Create: `backend/src/modules/home/` (2 files)
- Create: `backend/src/modules/profile/` (2 files)
- Create: `backend/src/app.module.ts`

- [ ] **Step 1: Create all auth module files**

Port from `backend/dist/modules/auth/`:
- `auth.module.ts`, `auth.controller.ts`, `auth.service.ts`, `auth.guard.ts`
- `current-user.decorator.ts`, `login.dto.ts`
- `auth-session.entity.ts`, `auth-session.repository.ts`

- [ ] **Step 2: Create home module**

```typescript
// home.module.ts
import { Module } from '@nestjs/common';
import { HomeController } from './controllers/home.controller';

@Module({
  controllers: [HomeController],
})
export class HomeModule {}
```

```typescript
// home.controller.ts
import { Controller, Get, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../../auth/guards/auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';

@Controller('home')
@UseGuards(AuthGuard)
export class HomeController {
  @Get()
  async getHome(@CurrentUser() user: any) {
    return {
      message: `Welcome back, ${user.name}`,
      profile: user,
      navigation: ['home', 'report', 'goals', 'profile'],
    };
  }
}
```

- [ ] **Step 3: Create profile module**

Port from `backend/dist/modules/profile/` — `profile.module.ts` and `profile.controller.ts`.

- [ ] **Step 4: Create app.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './modules/users/users.module';
import { AuthModule } from './modules/auth/auth.module';
import { HomeModule } from './modules/home/home.module';
import { ProfileModule } from './modules/profile/profile.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, envFilePath: '.env' }),
    TypeOrmModule.forRoot({
      type: 'mongodb',
      url: process.env.MONGODB_URI || 'mongodb://localhost:27017/moni_db',
      autoLoadEntities: true,
      synchronize: false,
      logging: true,
    }),
    UsersModule,
    AuthModule,
    HomeModule,
    ProfileModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
```

- [ ] **Step 5: Build and verify**

```bash
cd backend && npm run build
```

- [ ] **Step 6: Commit**

```bash
git add backend/src/
git commit -m "feat(be): restore auth, home, profile modules and app.module"
```

---

## Task 4: Create Categories Backend Module

**Files:**
- Create: `backend/src/modules/categories/entities/category.entity.ts`
- Create: `backend/src/modules/categories/dto/create-category.dto.ts`
- Create: `backend/src/modules/categories/repositories/category.repository.ts`
- Create: `backend/src/modules/categories/services/category.service.ts`
- Create: `backend/src/modules/categories/controllers/categories.controller.ts`
- Create: `backend/src/modules/categories/categories.module.ts`
- Modify: `backend/src/app.module.ts`

- [ ] **Step 1: Create category.entity.ts**

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('categories')
export class Category {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  icon: string;

  @Column({ nullable: true })
  type: string; // 'income' | 'expense'

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
```

- [ ] **Step 2: Create create-category.dto.ts**

```typescript
import { IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class CreateCategoryDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsOptional()
  @IsString()
  icon?: string;

  @IsOptional()
  @IsString()
  type?: string;
}
```

- [ ] **Step 3: Create category.repository.ts**

```typescript
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ObjectId } from 'mongodb';
import { Category } from '../entities/category.entity';

@Injectable()
export class CategoryRepository {
  constructor(
    @InjectRepository(Category)
    private readonly repository: Repository<Category>,
  ) {}

  async findByUserId(userId: string): Promise<Category[]> {
    return await this.repository.find({ where: { userId } });
  }

  async findById(id: string): Promise<Category> {
    return await this.repository.findOne({ where: { id: new ObjectId(id) } });
  }

  async create(data: Partial<Category>): Promise<Category> {
    const entity = this.repository.create(data);
    return await this.repository.save(entity);
  }

  async update(id: string, data: Partial<Category>): Promise<Category> {
    await this.repository.update({ id: new ObjectId(id) }, data);
    return await this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete({ id: new ObjectId(id) });
    return result.affected > 0;
  }
}
```

- [ ] **Step 4: Create category.service.ts**

```typescript
import { Injectable, NotFoundException } from '@nestjs/common';
import { CategoryRepository } from '../repositories/category.repository';
import { CreateCategoryDto } from '../dto/create-category.dto';

@Injectable()
export class CategoryService {
  constructor(private readonly repo: CategoryRepository) {}

  async findByUserId(userId: string) {
    return await this.repo.findByUserId(userId);
  }

  async create(userId: string, dto: CreateCategoryDto) {
    return await this.repo.create({
      userId,
      name: dto.name,
      icon: dto.icon ?? '📂',
      type: dto.type ?? 'expense',
    });
  }

  async update(id: string, dto: CreateCategoryDto) {
    const cat = await this.repo.findById(id);
    if (!cat) throw new NotFoundException('Category not found');
    return await this.repo.update(id, { name: dto.name, icon: dto.icon, type: dto.type });
  }

  async delete(id: string) {
    const result = await this.repo.delete(id);
    if (!result) throw new NotFoundException('Category not found');
    return { message: 'Category deleted' };
  }
}
```

- [ ] **Step 5: Create categories.controller.ts**

```typescript
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
```

- [ ] **Step 6: Create categories.module.ts**

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Category } from './entities/category.entity';
import { CategoriesController } from './controllers/categories.controller';
import { CategoryService } from './services/category.service';
import { CategoryRepository } from './repositories/category.repository';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [TypeOrmModule.forFeature([Category]), AuthModule],
  controllers: [CategoriesController],
  providers: [CategoryService, CategoryRepository],
})
export class CategoriesModule {}
```

- [ ] **Step 7: Add CategoriesModule to app.module.ts imports**

- [ ] **Step 8: Commit**

```bash
git add backend/src/modules/categories/ backend/src/app.module.ts
git commit -m "feat(be): add categories CRUD module"
```

---

## Task 5: Create PaymentMethods Backend Module

**Files:**
- Create: `backend/src/modules/payment-methods/` (all 6 files)
- Modify: `backend/src/app.module.ts`

- [ ] **Step 1: Create payment-method.entity.ts**

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('payment_methods')
export class PaymentMethod {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column()
  name: string;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
```

- [ ] **Step 2: Create dto, repository, service, controller, module**

Same pattern as Categories. Controller endpoints:
- `GET /payment-methods` → list by userId
- `POST /payment-methods` → create
- `DELETE /payment-methods/:id` → delete

DTO only needs `name` (IsNotEmpty, IsString).

- [ ] **Step 3: Register PaymentMethodsModule in app.module.ts**

- [ ] **Step 4: Commit**

```bash
git add backend/src/modules/payment-methods/ backend/src/app.module.ts
git commit -m "feat(be): add payment methods CRUD module"
```

---

## Task 6: Create Transactions Backend Module

**Files:**
- Create: `backend/src/modules/transactions/` (all 6 files)
- Modify: `backend/src/app.module.ts`

- [ ] **Step 1: Create transaction.entity.ts**

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('transactions')
export class Transaction {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column({ type: 'double precision' })
  amount: number;

  @Column()
  type: string; // 'income' | 'expense'

  @Column({ nullable: true })
  categoryId: string;

  @Column({ nullable: true })
  paymentMethodId: string;

  @Column({ nullable: true })
  note: string;

  @Column({ type: Date })
  date: Date;

  @Column({ nullable: true })
  feeling: string; // 'happy' | 'neutral' | 'regret'

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
```

- [ ] **Step 2: Create create-transaction.dto.ts**

```typescript
import { IsNotEmpty, IsOptional, IsString, IsNumber, IsDateString } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateTransactionDto {
  @IsNotEmpty()
  @Type(() => Number)
  @IsNumber()
  amount: number;

  @IsNotEmpty()
  @IsString()
  type: string;

  @IsOptional()
  @IsString()
  categoryId?: string;

  @IsOptional()
  @IsString()
  paymentMethodId?: string;

  @IsOptional()
  @IsString()
  note?: string;

  @IsNotEmpty()
  @IsDateString()
  date: string;

  @IsOptional()
  @IsString()
  feeling?: string;
}
```

- [ ] **Step 3: Create repository, service, controller, module**

Controller endpoints:
- `GET /transactions?from=&to=` → list by userId with optional date filter
- `POST /transactions` → create
- `PUT /transactions/:id` → update
- `DELETE /transactions/:id` → delete

Service `findByUserId(userId, from?, to?)` filters by date range when provided.

- [ ] **Step 4: Register TransactionsModule in app.module.ts**

- [ ] **Step 5: Commit**

```bash
git add backend/src/modules/transactions/ backend/src/app.module.ts
git commit -m "feat(be): add transactions CRUD module with date filtering"
```

---

## Task 7: Create Wishlist Backend Module

**Files:**
- Create: `backend/src/modules/wishlist/` (all 6 files)
- Modify: `backend/src/app.module.ts`

- [ ] **Step 1: Create wishlist-item.entity.ts**

```typescript
import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('wishlist_items')
export class WishlistItem {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column()
  name: string;

  @Column({ type: 'double precision' })
  price: number;

  @Column({ default: 'pending' })
  status: string; // 'pending' | 'completed'

  @Column({ nullable: true })
  imagePath: string;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
```

- [ ] **Step 2: Create dto, repository, service, controller, module**

Controller endpoints:
- `GET /wishlist` → list by userId
- `POST /wishlist` → create
- `PUT /wishlist/:id` → update
- `DELETE /wishlist/:id` → delete
- `PATCH /wishlist/:id/complete` → mark as completed

- [ ] **Step 3: Register WishlistModule in app.module.ts**

- [ ] **Step 4: Commit**

```bash
git add backend/src/modules/wishlist/ backend/src/app.module.ts
git commit -m "feat(be): add wishlist CRUD module"
```

---

## Task 8: Build and Verify Backend

- [ ] **Step 1: Build**

```bash
cd backend && npm run build
```

Expected: Compiles without errors.

- [ ] **Step 2: Start and smoke test**

```bash
cd backend && npm run start:dev
```

Test:
```bash
curl http://localhost:3000/
# Expected: "Smart Money API is running!"
```

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","name":"Test","password":"123456"}'
# Expected: { "access_token": "...", "user": {...} }
```

- [ ] **Step 3: Fix any compilation errors and commit**

---

## Task 9: Add Dio + API Config to Flutter

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/core/config/api_config.dart`
- Create: `lib/core/network/dio_client.dart`
- Create: `lib/core/network/auth_interceptor.dart`

- [ ] **Step 1: Add dio to pubspec.yaml dependencies**

```yaml
  dio: ^5.4.0
```

Run: `flutter pub get`

- [ ] **Step 2: Create api_config.dart**

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String profile = '/profile';
  static const String transactions = '/transactions';
  static const String categories = '/categories';
  static const String paymentMethods = '/payment-methods';
  static const String wishlist = '/wishlist';
}
```

- [ ] **Step 3: Create auth_interceptor.dart**

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  static const _tokenKey = 'auth_token';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      clearToken();
    }
    handler.next(err);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
```

- [ ] **Step 4: Create dio_client.dart**

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    if (_instance != null) return _instance!;
    _instance = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _instance!.interceptors.add(AuthInterceptor());
    return _instance!;
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add pubspec.yaml lib/core/config/ lib/core/network/
git commit -m "feat(fe): add Dio HTTP client, API config, and auth interceptor"
```

---

## Task 10: Create Remote Data Sources

**Files:**
- Create: `lib/data/datasources/auth_remote_data_source.dart`
- Create: `lib/data/datasources/transaction_remote_data_source.dart`
- Create: `lib/data/datasources/category_remote_data_source.dart`
- Create: `lib/data/datasources/payment_method_remote_data_source.dart`
- Create: `lib/data/datasources/wishlist_remote_data_source.dart`
- Create: `lib/data/datasources/profile_remote_data_source.dart`

- [ ] **Step 1: Create auth_remote_data_source.dart**

```dart
import 'package:dio/dio.dart';
import 'package:smart_money/core/config/api_config.dart';
import 'package:smart_money/core/network/dio_client.dart';
import 'package:smart_money/core/network/auth_interceptor.dart';

class AuthRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    final token = response.data['access_token'] as String;
    await AuthInterceptor.saveToken(token);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await _dio.post(ApiConfig.register, data: {
      'name': name,
      'email': email,
      'password': password,
    });
    final token = response.data['access_token'] as String;
    await AuthInterceptor.saveToken(token);
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _dio.post(ApiConfig.logout);
    await AuthInterceptor.clearToken();
  }
}
```

- [ ] **Step 2: Create remaining 5 data sources**

Each follows the same pattern: use `DioClient.instance` to call endpoints, parse responses with `Model.fromJson()`. Example for transactions:

```dart
class TransactionRemoteDataSource {
  final Dio _dio = DioClient.instance;

  Future<List<TransactionModel>> getTransactions({DateTime? from, DateTime? to}) async {
    final queryParams = <String, dynamic>{};
    if (from != null) queryParams['from'] = from.toIso8601String();
    if (to != null) queryParams['to'] = to.toIso8601String();
    final response = await _dio.get(ApiConfig.transactions, queryParameters: queryParams);
    return (response.data as List).map((e) => TransactionModel.fromJson(e)).toList();
  }

  Future<TransactionModel> addTransaction(TransactionModel txn) async {
    final response = await _dio.post(ApiConfig.transactions, data: txn.toJson());
    return TransactionModel.fromJson(response.data);
  }
  // ... update, delete similarly
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/
git commit -m "feat(fe): add remote data sources for all API endpoints"
```

---

## Task 11: Swap Repository Implementations to Use API

**Files:**
- Modify: `lib/data/repositories/repository_impl.dart`
- Modify: `lib/application/providers.dart`

- [ ] **Step 1: Rewrite repository_impl.dart**

Replace dummy data with API calls. Each repository now delegates to its remote data source:

```dart
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _dataSource;
  TransactionRepositoryImpl(this._dataSource);

  @override
  Future<List<TransactionModel>> getTransactions({DateTime? from, DateTime? to}) {
    return _dataSource.getTransactions(from: from, to: to);
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel txn) {
    return _dataSource.addTransaction(txn);
  }

  @override
  Future<void> updateTransaction(TransactionModel txn) {
    return _dataSource.updateTransaction(txn);
  }

  @override
  Future<void> deleteTransaction(String id) {
    return _dataSource.deleteTransaction(id);
  }
}
```

Same pattern for Category, PaymentMethod, Wishlist, Profile.

- [ ] **Step 2: Update providers.dart**

```dart
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(TransactionRemoteDataSource());
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(CategoryRemoteDataSource());
});
// ... same for paymentMethod, wishlist, profile
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/repositories/repository_impl.dart lib/application/providers.dart
git commit -m "feat(fe): swap repository implementations from dummy data to API calls"
```

---

## Task 12: Connect Login and SignUp to Backend API

**Files:**
- Modify: `lib/presentation/screens/auth/login_screen.dart`
- Modify: `lib/presentation/screens/auth/sign_up_screen.dart`
- Modify: `lib/application/providers.dart` (add auth provider)

- [ ] **Step 1: Add auth provider**

```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource();
});
```

- [ ] **Step 2: Update login_screen.dart `_handleLogin()`**

Replace `Future.delayed` with:

```dart
Future<void> _handleLogin() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    _showError('Please fill in all fields');
    return;
  }

  setState(() => _isLoading = true);

  try {
    final authDataSource = ref.read(authRemoteDataSourceProvider);
    await authDataSource.login(email, password);
    ref.read(isLoggedInProvider.notifier).login();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
      );
    }
  } catch (e) {
    if (mounted) _showError('Invalid email or password');
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

- [ ] **Step 3: Update sign_up_screen.dart `_handleSignUp()`**

Same pattern — call `authDataSource.register(name, email, password)`.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/auth/ lib/application/providers.dart
git commit -m "feat(fe): connect login and signup to backend API"
```

---

## Task 13: Update Profile Logout to Call API

**Files:**
- Modify: `lib/presentation/screens/profile/profile_screen.dart`

- [ ] **Step 1: Update logout handler**

Change the logout `onTap` to call the backend:

```dart
onTap: () async {
  try {
    final authDataSource = ref.read(authRemoteDataSourceProvider);
    await authDataSource.logout();
  } catch (_) {}
  ref.read(isLoggedInProvider.notifier).logout();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
},
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/profile/profile_screen.dart
git commit -m "feat(fe): connect logout to backend API"
```

---

## Task 14: End-to-End Testing and Bug Fixes

- [ ] **Step 1: Start backend** — `cd backend && npm run start:dev`
- [ ] **Step 2: Start Flutter app** — `flutter run`
- [ ] **Step 3: Test complete flow**

1. Register a new account
2. Login with the account
3. Verify home screen loads (empty transactions)
4. Add a category from Profile → Manage Categories
5. Add a payment method from Profile → Manage Payment Methods
6. Add a transaction
7. Verify transaction appears in Home and Report screens
8. Add a wishlist item
9. Check profile screen shows user data
10. Logout and login again — verify data persists from MongoDB

- [ ] **Step 4: Fix any issues found and commit**

---

## Summary

| Phase | Tasks | What It Produces |
|-------|-------|-----------------|
| Backend Restore | 1-3 | All existing BE source code restored from compiled JS |
| New BE Modules | 4-7 | Categories, PaymentMethods, Transactions, Wishlist CRUD endpoints |
| BE Verification | 8 | Confirmed working backend |
| FE Infrastructure | 9 | Dio HTTP client, API config, auth interceptor |
| FE Data Sources | 10 | Remote data sources for all 6 API domains |
| FE Repository Swap | 11 | Dummy data replaced with real API calls |
| FE Auth Connection | 12-13 | Login/Signup/Logout connected to backend |
| E2E Testing | 14 | Full flow verified, bugs fixed |
