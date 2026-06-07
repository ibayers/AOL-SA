import { Entity, Column, ObjectIdColumn, CreateDateColumn } from 'typeorm';
import { ObjectId } from 'mongodb';

@Entity('wishlist_items')
export class WishlistItem {
  @ObjectIdColumn()
  id: ObjectId;

  @Column()
  userId: string;

  @Column()
  name: string;

  @Column({ type: 'double precision' })
  price: number;

  @Column({ type: 'double precision', default: 0 })
  savedAmount: number;

  @Column({ default: 'pending' })
  status: string;

  @Column({ nullable: true })
  imagePath: string;

  @CreateDateColumn({ type: Date })
  createdAt: Date;
}
