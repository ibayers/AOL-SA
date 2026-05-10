import { UserService } from "../services/user.service";
import { CreateUserDto } from "../dto/create-user.dto";
import { UpdateUserDto } from "../dto/update-user.dto";
export declare class UserController {
    private readonly userService;
    constructor(userService: UserService);
    create(createUserDto: CreateUserDto): Promise<import("../mappers/user-response.mapper").PublicUserProfile>;
    findAll(skip?: number, take?: number): Promise<{
        data: import("../mappers/user-response.mapper").PublicUserProfile[];
        total: number;
    }>;
    findById(id: string): Promise<import("../mappers/user-response.mapper").PublicUserProfile>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<import("../mappers/user-response.mapper").PublicUserProfile>;
    delete(id: string): Promise<{
        message: string;
    }>;
}
