import { UpdateUserDto } from "../../users/dto/update-user.dto";
import { UserService } from "../../users/services/user.service";
export declare class ProfileController {
    private readonly userService;
    constructor(userService: UserService);
    getProfile(user: any): Promise<any>;
    updateProfile(userId: string, updateUserDto: UpdateUserDto): Promise<import("../../users/mappers/user-response.mapper").PublicUserProfile>;
}
