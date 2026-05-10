import { Controller, Get, Post, Body, Param, Put, Delete, Query, HttpCode, HttpStatus } from "@nestjs/common";
import { UserService } from "../services/user.service";
import { CreateUserDto } from "../dto/create-user.dto";
import { UpdateUserDto } from "../dto/update-user.dto";
import { User } from "../entities/user.entity";
import { toPublicUserProfile } from "../mappers/user-response.mapper";

@Controller("users")
export class UserController {
  constructor(private readonly userService: UserService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createUserDto: CreateUserDto) {
    const user = await this.userService.create(createUserDto);
    return toPublicUserProfile(user);
  }

  @Get()
  async findAll(
    @Query("skip") skip: number = 0,
    @Query("take") take: number = 10
  ) {
    const { data, total } = await this.userService.findAll(skip, take);
    return { data: data.map((user) => toPublicUserProfile(user)), total };
  }

  @Get(":id")
  async findById(@Param("id") id: string) {
    const user = await this.userService.findById(id);
    return toPublicUserProfile(user);
  }

  @Put(":id")
  async update(
    @Param("id") id: string,
    @Body() updateUserDto: UpdateUserDto
  ) {
    const user = await this.userService.update(id, updateUserDto);
    return toPublicUserProfile(user);
  }

  @Delete(":id")
  @HttpCode(HttpStatus.OK)
  async delete(@Param("id") id: string): Promise<{ message: string }> {
    return await this.userService.delete(id);
  }
}
