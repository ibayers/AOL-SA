import { Repository } from "typeorm";
import { User } from "../entities/user.entity";
export declare class UserRepository {
    private readonly repository;
    constructor(repository: Repository<User>);
    create(userData: Partial<User>): Promise<User>;
    findById(id: string): Promise<User | null>;
    findByEmail(email: string): Promise<User | null>;
    findAll(skip?: number, take?: number): Promise<[User[], number]>;
    update(id: string, updateData: Partial<User>): Promise<User | null>;
    delete(id: string): Promise<boolean>;
}
