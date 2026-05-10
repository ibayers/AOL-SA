import { Body, Controller, Get, Patch, UseGuards } from "@nestjs/common";
import { AuthGuard } from "../../auth/guards/auth.guard";
import { CurrentUser } from "../../auth/decorators/current-user.decorator";
import { UpdateUserDto } from "../../users/dto/update-user.dto";
import { UserService } from "../../users/services/user.service";

@Controller("profile")
@UseGuards(AuthGuard)
export class ProfileController {
  constructor(private readonly userService: UserService) {}

  @Get()
  async getProfile(@CurrentUser() user: any) {
    return user;
  }

  @Patch()
  async updateProfile(@CurrentUser("id") userId: string, @Body() updateUserDto: UpdateUserDto) {
    const user = await this.userService.update(userId, updateUserDto);
    return this.userService.toPublicProfile(user);
  }
}