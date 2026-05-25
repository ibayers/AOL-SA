import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('transactions')
export class Transaction {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column({ type: 'double precision' })
  amount: number;

  @Column()
  type: string;

  @Column({ nullable: true })
  categoryId: string;

  @Column({ nullable: true })
  paymentMethodId: string;

  @Column({ nullable: true })
  note: string;

  @Column({ type: Date })
  date: Date;

  @Column({ nullable: true })
  feeling: string;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
