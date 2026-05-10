import { Injectable, BadRequestException, NotFoundException } from "@nestjs/common";
import { CreateUserDto } from "../dto/create-user.dto";
import { UpdateUserDto } from "../dto/update-user.dto";
import { User } from "../entities/user.entity";
import { UserRepository } from "../repositories/user.repository";
import { hashPassword } from "../../../common/security/crypto.util";
import { PublicUserProfile, toPublicUserProfile } from "../mappers/user-response.mapper";

@Injectable()
export class UserService {
  constructor(private readonly userRepository: UserRepository) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const existingUser = await this.userRepository.findByEmail(createUserDto.email);
    if (existingUser) {
      throw new BadRequestException("User with this email already exists");
    }

    return await this.userRepository.create({
      email: createUserDto.email,
      name: createUserDto.name,
      passwordHash: hashPassword(createUserDto.password),
      role: createUserDto.role ?? "user",
      avatarUrl: createUserDto.avatarUrl ?? null,
      weeklyBudget: createUserDto.weeklyBudget ?? 0
    });
  }

  async findById(id: string): Promise<User> {
    const user = await this.userRepository.findById(id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  async findByEmail(email: string): Promise<User | null> {
    return await this.userRepository.findByEmail(email);
  }

  async findAll(skip: number = 0, take: number = 10): Promise<{ data: User[]; total: number }> {
    const [data, total] = await this.userRepository.findAll(skip, take);
    return { data, total };
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const currentUser = await this.findById(id);
    if (updateUserDto.email) {
      const existingUser = await this.userRepository.findByEmail(updateUserDto.email);
      if (existingUser && existingUser.id.toHexString() !== id) {
        throw new BadRequestException("Email already in use");
      }
    }

    const updatedUser = await this.userRepository.update(id, {
      email: updateUserDto.email,
      name: updateUserDto.name,
      passwordHash: updateUserDto.password ? hashPassword(updateUserDto.password) : currentUser.passwordHash,
      role: updateUserDto.role,
      avatarUrl: updateUserDto.avatarUrl,
      weeklyBudget: updateUserDto.weeklyBudget
    });
    if (!updatedUser) {
      throw new NotFoundException("Failed to update user");
    }
    return updatedUser;
  }

  async delete(id: string): Promise<{ message: string }> {
    await this.findById(id);
    const result = await this.userRepository.delete(id);
    if (!result) {
      throw new NotFoundException("Failed to delete user");
    }
    return { message: "User deleted successfully" };
  }

  toPublicProfile(user: User): PublicUserProfile {
    return toPublicUserProfile(user);
  }
}
