import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('payment_methods')
export class PaymentMethod {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column()
  name: string;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
