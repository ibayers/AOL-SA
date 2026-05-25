import { Injectable } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { ObjectId } from "mongodb";
import { Repository } from "typeorm";
import { User } from "../entities/user.entity";
import { UpdateUserDto } from "../dto/update-user.dto";

@Injectable()
export class UserRepository {
  constructor(
    @InjectRepository(User)
    private readonly repository: Repository<User>
  ) {}

  async create(userData: Partial<User>): Promise<User> {
    const user = this.repository.create(userData);
    return await this.repository.save(user);
  }

  async findById(id: string): Promise<User | null> {
    return await this.repository.findOne({ where: { _id: new ObjectId(id) } } as any);
  }

  async findByEmail(email: string): Promise<User | null> {
    return await this.repository.findOne({ where: { email } });
  }

  async findAll(skip: number = 0, take: number = 10): Promise<[User[], number]> {
    return await this.repository.findAndCount({ skip, take });
  }

  async update(id: string, updateData: Partial<User>): Promise<User | null> {
    await this.repository.update({ _id: new ObjectId(id) } as any, updateData);
    return await this.findById(id);
  }

  async delete(id: string): Promise<boolean> {
    const result = await this.repository.delete({ _id: new ObjectId(id) } as any);
    return result.affected > 0;
  }
}
