export declare class HomeController {
    getHome(user: any): Promise<{
        message: string;
        profile: any;
        navigation: string[];
    }>;
}
