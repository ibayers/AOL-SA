import { Controller, Get, UseGuards } from "@nestjs/common";
import { AuthGuard } from "../../auth/guards/auth.guard";
import { CurrentUser } from "../../auth/decorators/current-user.decorator";

@Controller("home")
@UseGuards(AuthGuard)
export class HomeController {
  @Get()
  async getHome(@CurrentUser() user: any) {
    return {
      message: `Welcome back, ${user.name}`,
      profile: user,
      navigation: ["home", "report", "goals", "profile"]
    };
  }
}