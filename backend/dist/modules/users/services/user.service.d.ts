import { CreateUserDto } from "../dto/create-user.dto";
import { UpdateUserDto } from "../dto/update-user.dto";
import { User } from "../entities/user.entity";
import { UserRepository } from "../repositories/user.repository";
import { PublicUserProfile } from "../mappers/user-response.mapper";
export declare class UserService {
    private readonly userRepository;
    constructor(userRepository: UserRepository);
    create(createUserDto: CreateUserDto): Promise<User>;
    findById(id: string): Promise<User>;
    findByEmail(email: string): Promise<User | null>;
    findAll(skip?: number, take?: number): Promise<{
        data: User[];
        total: number;
    }>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<User>;
    delete(id: string): Promise<{
        message: string;
    }>;
    toPublicProfile(user: User): PublicUserProfile;
}
