Aplikasi Moni

BACK-END (NestJS + MongoDB)

Teknologi

- Framework: NestJS v9 (berjalan di atas Express)
- Database: MongoDB Atlas (cloud, nama database DaurinApp_db)
- ORM: TypeORM v0.3.17
- Validasi: class-validator + class-transformer
- Port: 3000

Arsitektur

Backend menggunakan pola Modular Layered Architecture sesuai konvensi NestJS. Setiap module memiliki Controller (routing HTTP), Service
(business logic), Repository (data access), DTO (validasi input), Entity (model database), dan Mapper (transformasi response).

src/  
 ├── main.ts # Entry point (CORS, ValidationPipe, ExceptionFilter)
├── app.module.ts # Root module (ConfigModule + TypeOrmModule)
├── common/
│ ├── filters/ # Global HTTP exception handler
│ └── security/ # Crypto utils (PBKDF2, SHA-256, token generation)
└── modules/  
 ├── users/ # CRUD user (entity, DTO, repository, service, mapper)
├── auth/ # Auth (register, login, logout, session management)  
 ├── home/ # Home endpoint (auth-protected)
└── profile/ # Profile view & update (auth-protected)

Database — 2 Collection

users — menyimpan data user dengan field email (unique), name, passwordHash, avatarUrl, weeklyBudget, role (default "user"), isActive  
 (default true), serta createdAt dan updatedAt.

auth_sessions — menyimpan session token dengan field tokenHash (unique), userId (relasi ke users), userAgent, expiresAt, dan revokedAt
(nullable, diisi saat logout).

Autentikasi (Custom Token-Based, bukan JWT)

Sistem autentikasi menggunakan token-based custom, bukan JWT. Alurnya:

- Register → buat user baru → generate session token → simpan hash token ke database → kembalikan raw token ke client.
- Login → verifikasi password menggunakan PBKDF2 dengan SHA-512 (120.000 iterasi) → buat session baru → kembalikan token.
- Logout → revoke session dengan mengisi field revokedAt.
- Token disimpan sebagai SHA-256 hash di database, bukan plain text, sehingga jika database bocor, token tidak bisa langsung dipakai.

AuthGuard menangkap header Authorization: Bearer <token>, memvalidasi token ke database, lalu menempelkan data user ke request.
Terdapat juga custom decorator @CurrentUser() untuk mengambil data user yang sedang login.

API Endpoints (14 total)

Public (tanpa auth):

- GET / — health check, mengembalikan teks "Hello World!"
- GET /health — mengembalikan JSON { status: "OK" }
- POST /users — membuat user baru, membutuhkan email, name, password (min 6 karakter)
- GET /users — list semua user dengan pagination (query param skip dan take)
- GET /users/:id — detail satu user berdasarkan ID
- PUT /users/:id — update data user
- DELETE /users/:id — hapus user
- POST /auth/register — register sekaligus auto-login, mengembalikan access_token dan user profile
- POST /auth/login — login dengan email dan password, mengembalikan access_token dan user profile

Protected (butuh Bearer token):

- POST /auth/logout — revoke session, menghapus akses token
- GET /auth/me — mengembalikan profil user yang sedang login
- GET /home — mengembalikan welcome message, user profile, dan array navigasi ["home", "report", "goals", "profile"]
- GET /profile — melihat profil user yang sedang login
- PATCH /profile — mengupdate profil (name, email, password, avatar, weeklyBudget)

Shared Utilities

Http Exception Filter — menangkap semua HttpException dan mengembalikan response JSON yang konsisten berisi statusCode, message, dan
timestamp.

Konfigurasi
Konfigurasi diatur melalui file .env dengan tiga variabel: PORT (default 3000), NODE_ENV (development), dan MONGODB_URI (connection  
 string MongoDB Atlas). Jika MONGODB_URI tidak diset, aplikasi akan fallback ke mongodb://localhost:27017/moni_db. Session TTL diatur
melalui AUTH_SESSION_TTL_HOURS dengan default 168 jam (7 hari).
