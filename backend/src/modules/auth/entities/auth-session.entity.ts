import { Column, CreateDateColumn, Entity, Index, ObjectIdColumn } from "typeorm";
import { ObjectId } from "mongodb";

@Entity("auth_sessions")
export class AuthSession {
  @ObjectIdColumn()
  id: ObjectId;

  @Index({ unique: true })
  @Column({ type: "varchar" })
  tokenHash: string;

  @Column()
  userId: ObjectId;

  @Column({ type: "varchar", nullable: true })
  userAgent: string | null;

  @Column({ type: Date })
  expiresAt: Date;

  @Column({ type: Date, nullable: true })
  revokedAt: Date | null;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}