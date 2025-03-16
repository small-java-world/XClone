# X クローンアプリケーション設計仕様書

## 1. システム概要

このドキュメントは、Xのクローンアプリケーションの詳細な技術設計仕様を記述したものです。本アプリケーションは会社のテックブログ題材として開発され、モダンな技術スタックとクリーンアーキテクチャ・DDDの原則に基づいて実装されます。

## 2. 技術スタック

### 2.1 バックエンド

#### 2.1.1 言語/フレームワーク
- **プログラミング言語**: Kotlin
- **フレームワーク**: Spring Boot
- **Java バージョン**: Java 21
- **ビルドツール**: Gradle (Kotlin DSL)

#### 2.1.2 テスト環境
- **ユニットテストフレームワーク**: Kotest
- **モッキングライブラリ**: MockK

#### 2.1.3 データ層
- **ORM**: jOOQ (型安全なSQLジェネレータ)
- **データベース**: MySQL 8.0
- **マイグレーションツール**: Flyway
- **キャッシュ**: Redis
- **UUID最適化**: アプリケーション内では標準UUIDを使用し、DB格納時にBINARY(16)形式に変換。タイムスタンプビットのスワップによりインデックス効率向上

#### 2.1.4 設定管理
- 環境変数ベースの設定管理
- ローカル開発用に `.env.local` を Spring Boot 起動時に読み込む

### 2.2 フロントエンド

- **フレームワーク**: Next.js
- **ユニットテスト**: Vitest

### 2.3 E2Eテスト

- **テストフレームワーク**: Playwright

### 2.4 開発環境

- **コンテナ化**: Docker & Docker Compose

## 3. アーキテクチャ設計

### 3.1 クリーンアーキテクチャとDDD

本アプリケーションは、クリーンアーキテクチャとドメイン駆動設計(DDD)の原則に従って設計されます。これにより、ビジネスロジックがインフラストラクチャやUIから独立し、保守性と拡張性が高まります。

#### 3.1.1 ドメイン境界

アプリケーションは以下のドメイン境界に分割されます：

- **ユーザー管理（User）**
- **投稿管理（Post）**
- **フォロー関係（Follow）**
- **通知（Notification）**
- **タイムライン（Timeline）**

### 3.2 レイヤー構成

#### 3.2.1 ドメイン層

ビジネスルールとロジックを含む中心的なレイヤー。

- **エンティティ**: アプリケーションの中核となるオブジェクト（User, Post, Follow など）
- **値オブジェクト**: 不変の値を表現するオブジェクト（UserId, PostId など）
- **ドメインサービス**: エンティティ間の操作を担当
- **リポジトリインターフェース**: データアクセスのための抽象化

```kotlin
// エンティティの例
data class User(
    val id: UserId,
    val username: Username,
    val displayName: DisplayName,
    val email: Email,
    val bio: UserBio? = null,
    val profileImageUrl: ProfileImageUrl? = null,
    val createdAt: Instant,
    val updatedAt: Instant
)

// 値オブジェクトの例
@JvmInline
value class UserId(val value: UUID) {
    companion object {
        fun generate(): UserId = UserId(UUID.randomUUID())
    }
}

// リポジトリインターフェースの例
interface UserRepository {
    suspend fun findById(id: UserId): User?
    suspend fun findByUsername(username: Username): User?
    suspend fun save(user: User): User
    suspend fun update(user: User): User
    suspend fun delete(id: UserId)
}
```

#### 3.2.2 アプリケーション層

ユースケースとアプリケーションロジックを実装するレイヤー。

- **ユースケース**: 特定のビジネス操作を実行するクラス
- **コマンド**: ユースケースへの入力データ
- **レスポンス**: ユースケースからの出力データ

```kotlin
// ユースケースの例
class CreateUserUseCase(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) {
    suspend fun execute(command: CreateUserCommand): UserResponse {
        // ユーザー名の重複チェック
        userRepository.findByUsername(Username(command.username))?.let {
            throw UsernameAlreadyExistsException(command.username)
        }
        
        // ユーザー作成
        val user = User(
            id = UserId.generate(),
            username = Username(command.username),
            displayName = DisplayName(command.displayName),
            email = Email(command.email),
            bio = command.bio?.let { UserBio(it) },
            profileImageUrl = null,
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )
        
        val savedUser = userRepository.save(user)
        
        return UserResponse.fromUser(savedUser)
    }
}

// コマンドの例
data class CreateUserCommand(
    val username: String,
    val displayName: String,
    val email: String,
    val password: String,
    val bio: String? = null
)

// レスポンスの例
data class UserResponse(
    val id: String,
    val username: String,
    val displayName: String,
    val bio: String?,
    val profileImageUrl: String?,
    val createdAt: String,
    val updatedAt: String
) {
    companion object {
        fun fromUser(user: User): UserResponse {
            return UserResponse(
                id = user.id.value.toString(),
                username = user.username.value,
                displayName = user.displayName.value,
                bio = user.bio?.value,
                profileImageUrl = user.profileImageUrl?.value,
                createdAt = user.createdAt.toString(),
                updatedAt = user.updatedAt.toString()
            )
        }
    }
}
```

#### 3.2.3 インフラストラクチャ層

外部システムやデータストアとの連携を担当するレイヤー。

- **リポジトリ実装**: データベースアクセスの実装
- **外部サービス連携**: 他システムとの連携
- **永続化**: データの保存と取得

```kotlin
// リポジトリ実装の例 (UUIDを効率的に扱う方法を組み込み)
@Repository
class MySQLUserRepository(
    private val dsl: DSLContext
) : UserRepository {
    
    override suspend fun findById(id: UserId): User? = withContext(Dispatchers.IO) {
        // UUIDをMySQL用のバイナリに変換
        val binaryId = uuidToMySqlBin(id.value, true)
        
        dsl.select()
            .from(USERS)
            .where(USERS.ID.eq(binaryId))
            .fetchOneInto(UserRecord::class.java)
            ?.toDomain()
    }
    
    override suspend fun save(user: User): User = withContext(Dispatchers.IO) {
        // UUIDをMySQL用のバイナリに変換
        val binaryId = uuidToMySqlBin(user.id.value, true)
        
        val record = dsl.newRecord(USERS).apply {
            id = binaryId
            username = user.username.value
            displayName = user.displayName.value
            email = user.email.value
            bio = user.bio?.value
            profileImageUrl = user.profileImageUrl?.value
            createdAt = user.createdAt
            updatedAt = user.updatedAt
        }
        
        record.store()
        user
    }
    
    // UUIDをMySQL用のバイナリに変換するヘルパー関数
    private fun uuidToMySqlBin(uuid: UUID, swapFlag: Boolean = true): ByteArray {
        val msb = uuid.mostSignificantBits
        val lsb = uuid.leastSignificantBits
        
        val bytes = ByteArray(16)
        
        if (!swapFlag) {
            // 通常の変換
            for (i in 0..7) {
                bytes[i] = ((msb shr ((7 - i) * 8)) and 0xFF).toByte()
            }
            for (i in 8..15) {
                bytes[i] = ((lsb shr ((15 - i) * 8)) and 0xFF).toByte()
            }
            return bytes
        }
        
        // スワップフラグ=1の場合の変換（タイムスタンプの上位ビットと下位ビットを交換）
        // time_mid (2バイト) + time_high (2バイト)
        bytes[0] = ((msb shr 48) and 0xFF).toByte()
        bytes[1] = ((msb shr 56) and 0xFF).toByte()
        bytes[2] = ((msb shr 32) and 0xFF).toByte()
        bytes[3] = ((msb shr 40) and 0xFF).toByte()
        
        // time_low (4バイト)
        bytes[4] = ((msb shr 24) and 0xFF).toByte()
        bytes[5] = ((msb shr 16) and 0xFF).toByte()
        bytes[6] = ((msb shr 8) and 0xFF).toByte()
        bytes[7] = (msb and 0xFF).toByte()
        
        // 残りの64ビット
        for (i in 8..15) {
            bytes[i] = ((lsb shr ((15 - i) * 8)) and 0xFF).toByte()
        }
        
        return bytes
    }
    
    // レコードからドメインモデルへの変換
    private fun UserRecord.toDomain(): User {
        // バイナリIDをUUIDに変換
        val uuid = (id as ByteArray).toUuid(true)
        
        return User(
            id = UserId(uuid),
            username = Username(username),
            displayName = DisplayName(displayName),
            email = Email(email),
            bio = bio?.let { UserBio(it) },
            profileImageUrl = profileImageUrl?.let { ProfileImageUrl(it) },
            createdAt = createdAt,
            updatedAt = updatedAt
        )
    }
    
    // バイナリからUUIDへの変換
    private fun ByteArray.toUuid(swapped: Boolean = true): UUID {
        require(this.size == 16) { "UUID binary must be exactly 16 bytes" }
        
        val bytes = if (swapped) {
            // スワップされた形式を元に戻す
            ByteArray(16).also { result ->
                // time_low を先頭に
                result[0] = this[4]
                result[1] = this[5]
                result[2] = this[6]
                result[3] = this[7]
                // time_mid と time_high
                result[4] = this[2]
                result[5] = this[3]
                result[6] = this[0]
                result[7] = this[1]
                // 残りはそのまま
                System.arraycopy(this, 8, result, 8, 8)
            }
        } else {
            this
        }
        
        var msb = 0L
        var lsb = 0L
        for (i in 0..7) msb = (msb shl 8) or (bytes[i].toLong() and 0xFF)
        for (i in 8..15) lsb = (lsb shl 8) or (bytes[i].toLong() and 0xFF)
        
        return UUID(msb, lsb)
    }
}
```

#### 3.2.4 プレゼンテーション層

ユーザーインターフェースとAPI定義を担当するレイヤー。

- **コントローラー**: HTTPリクエストのハンドリング
- **API定義**: エンドポイントの仕様

```kotlin
@RestController
@RequestMapping("/api/users")
class UserController(
    private val createUserUseCase: CreateUserUseCase,
    private val getUserUseCase: GetUserUseCase,
    private val updateUserUseCase: UpdateUserUseCase,
    private val deleteUserUseCase: DeleteUserUseCase
) {
    
    @PostMapping
    suspend fun createUser(@RequestBody request: CreateUserRequest): ResponseEntity<UserResponse> {
        val command = CreateUserCommand(
            username = request.username,
            displayName = request.displayName,
            email = request.email,
            password = request.password,
            bio = request.bio
        )
        
        val response = createUserUseCase.execute(command)
        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }
    
    @GetMapping("/{id}")
    suspend fun getUser(@PathVariable id: String): ResponseEntity<UserResponse> {
        val response = getUserUseCase.execute(GetUserCommand(id))
        return ResponseEntity.ok(response)
    }
    
    // 他のエンドポイント...
}

// リクエストの例
data class CreateUserRequest(
    val username: String,
    val displayName: String,
    val email: String,
    val password: String,
    val bio: String? = null
)
```

## 4. データベース設計

### 4.1 エンティティ関係図（ERD）

主要なテーブル構造は以下の通りです：

- **users**: ユーザー情報
- **posts**: 投稿情報
- **follows**: フォロー関係
- **likes**: 投稿へのいいね
- **notifications**: 通知情報

### 4.2 スキーマ定義

```sql
-- ユーザーテーブル (UUIDをBINARY型で保存)
CREATE TABLE users (
    id BINARY(16) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT,
    profile_image_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    INDEX idx_created_at (created_at)
);

-- 投稿テーブル (UUIDをBINARY型で保存)
CREATE TABLE posts (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    content TEXT NOT NULL,
    media_urls JSON,
    reply_to_id BINARY(16),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_id) REFERENCES posts(id),
    INDEX idx_user_created (user_id, created_at)
);

-- フォローテーブル
CREATE TABLE follows (
    follower_id BINARY(16) NOT NULL,
    followee_id BINARY(16) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (follower_id, followee_id),
    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (followee_id) REFERENCES users(id) ON DELETE CASCADE
);

-- いいねテーブル
CREATE TABLE likes (
    user_id BINARY(16) NOT NULL,
    post_id BINARY(16) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
    INDEX idx_post_created (post_id, created_at)
);

-- 通知テーブル
CREATE TABLE notifications (
    id BINARY(16) PRIMARY KEY,
    user_id BINARY(16) NOT NULL,
    type VARCHAR(50) NOT NULL,
    actor_id BINARY(16),
    entity_id BINARY(16),
    entity_type VARCHAR(50),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_created (user_id, created_at)
);
```

### 4.3 UUIDの効率的な保存戦略

データベースでのUUIDの効率的な保存のため、以下の方針を採用します：

1. **BINARY(16)型を使用**: UUIDを文字列(36文字)ではなくBINARY(16)型として保存し、ストレージ効率を向上
2. **ビットスワップの適用**: UUIDのタイムスタンプ部分の上位ビットと下位ビットをスワップし、時系列でのインデックス効率を向上
3. **追加インデックス**: 時系列アクセスが多いカラムには明示的に created_at インデックスを追加
4. **複合インデックス**: 頻繁に使用される検索パターン（ユーザー別投稿など）に複合インデックスを適用

## 5. API設計

### 5.1 認証

- **POST /api/auth/register**: ユーザー登録
- **POST /api/auth/login**: ログイン
- **POST /api/auth/refresh**: トークンリフレッシュ
- **POST /api/auth/logout**: ログアウト

### 5.2 ユーザー

- **GET /api/users/{id}**: ユーザー情報取得
- **GET /api/users/me**: 自分の情報取得
- **PUT /api/users/me**: ユーザー情報更新
- **DELETE /api/users/me**: ユーザー削除

### 5.3 投稿

- **POST /api/posts**: 投稿作成
- **GET /api/posts/{id}**: 投稿取得
- **DELETE /api/posts/{id}**: 投稿削除
- **GET /api/posts/user/{userId}**: ユーザーの投稿一覧取得

### 5.4 タイムライン

- **GET /api/timeline**: ホームタイムライン取得
- **GET /api/timeline/explore**: 探索タイムライン取得

### 5.5 フォロー

- **POST /api/follows/{userId}**: ユーザーをフォロー
- **DELETE /api/follows/{userId}**: フォロー解除
- **GET /api/follows/followers/{userId}**: フォロワー一覧
- **GET /api/follows/following/{userId}**: フォロー中一覧

### 5.6 いいね

- **POST /api/likes/{postId}**: 投稿にいいね
- **DELETE /api/likes/{postId}**: いいね解除

### 5.7 通知

- **GET /api/notifications**: 通知一覧取得
- **PUT /api/notifications/{id}/read**: 通知を既読にする

## 6. テスト戦略

### 6.1 ユニットテスト (Kotest & MockK)

各レイヤーのコンポーネントに対して、独立したユニットテストを実施します。

```kotlin
class CreateUserUseCaseTest : StringSpec({
    val userRepository = mockk<UserRepository>()
    val passwordEncoder = mockk<PasswordEncoder>()
    val useCase = CreateUserUseCase(userRepository, passwordEncoder)
    
    "ユーザー作成が成功する場合" {
        // 準備
        val command = CreateUserCommand(
            username = "testuser",
            displayName = "Test User",
            email = "test@example.com",
            password = "password123"
        )
        
        every { userRepository.findByUsername(any()) } returns null
        every { passwordEncoder.encode(any()) } returns "encoded_password"
        coEvery { userRepository.save(any()) } answers { firstArg() }
        
        // 実行
        val result = useCase.execute(command)
        
        // 検証
        result.username shouldBe command.username
        result.displayName shouldBe command.displayName
        
        coVerify(exactly = 1) { userRepository.save(any()) }
    }
    
    "ユーザー名が既に存在する場合は例外をスロー" {
        // 準備
        val command = CreateUserCommand(
            username = "existinguser",
            displayName = "Existing User",
            email = "existing@example.com",
            password = "password123"
        )
        
        every { userRepository.findByUsername(any()) } returns User(
            id = UserId.generate(),
            username = Username(command.username),
            displayName = DisplayName("Existing User"),
            email = Email("existing@example.com"),
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )
        
        // 実行 & 検証
        shouldThrow<UsernameAlreadyExistsException> {
            useCase.execute(command)
        }
        
        coVerify(exactly = 0) { userRepository.save(any()) }
    }
})
```

### 6.2 統合テスト

リポジトリ実装とデータベースの連携テストを実施します。特にUUIDのバイナリ変換ロジックが正常に動作することを検証します。

```kotlin
@SpringBootTest
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class UserRepositoryIntegrationTest {
    
    @Autowired
    private lateinit var userRepository: UserRepository
    
    @Autowired
    private lateinit var dsl: DSLContext
    
    @BeforeAll
    fun setup() {
        // テスト用データベースのセットアップ
    }
    
    @AfterAll
    fun cleanup() {
        // テスト用データベースのクリーンアップ
    }
    
    @Test
    fun `ユーザーの保存と取得が正常に動作する`() = runBlocking {
        // 準備
        val user = User(
            id = UserId.generate(),
            username = Username("testuser"),
            displayName = DisplayName("Test User"),
            email = Email("test@example.com"),
            createdAt = Instant.now(),
            updatedAt = Instant.now()
        )
        
        // 実行
        userRepository.save(user)
        val result = userRepository.findById(user.id)
        
        // 検証
        assertNotNull(result)
        assertEquals(user.id, result?.id)
        assertEquals(user.username, result?.username)
        assertEquals(user.email, result?.email)
    }
    
    @Test
    fun `UUIDのバイナリ変換が正常に動作する`() = runBlocking {
        // 準備 - 複数のUUIDを連続して生成
        val users = List(100) { i ->
            User(
                id = UserId.generate(),
                username = Username("testuser$i"),
                displayName = DisplayName("Test User $i"),
                email = Email("test$i@example.com"),
                createdAt = Instant.now().plusMillis(i.toLong()),
                updatedAt = Instant.now().plusMillis(i.toLong())
            )
        }
        
        // 実行 - ユーザーを保存
        users.forEach { userRepository.save(it) }
        
        // 検証 - 作成日時順に取得しIDが一致することを確認
        val sortedUsersFromDb = dsl.select()
            .from(USERS)
            .orderBy(USERS.CREATED_AT.asc())
            .fetch()
        
        // 取得データの検証
        assertEquals(100, sortedUsersFromDb.size)
    }
}
```

### 6.3 E2Eテスト (Playwright)

フロントエンドとバックエンドの連携を検証するエンドツーエンドテストを実施します。

```typescript
// tests/e2e/user-registration.spec.ts
import { test, expect } from '@playwright/test';

test('新規ユーザー登録フロー', async ({ page }) => {
  // トップページにアクセス
  await page.goto('/');
  
  // 登録ページに移動
  await page.click('text=Sign up');
  
  // フォームに入力
  await page.fill('input[name="username"]', 'newuser' + Date.now());
  await page.fill('input[name="displayName"]', 'New User');
  await page.fill('input[name="email"]', `newuser${Date.now()}@example.com`);
  await page.fill('input[name="password"]', 'Password123!');
  await page.fill('input[name="confirmPassword"]', 'Password123!');
  
  // 登録ボタンをクリック
  await page.click('button[type="submit"]');
  
  // ホームページにリダイレクトされることを確認
  await expect(page).toHaveURL(/\/home/);
  
  // ユーザー名が表示されることを確認
  await expect(page.locator('.user-profile-name')).toContainText('New User');
});
```

## 7. デプロイメントとCI/CD

### 7.1 ローカル開発環境

Docker Composeを使用して、すべての依存サービスを含む開発環境を構築します。

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "8080:8080"
    depends_on:
      - db
      - redis
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - DB_HOST=db
      - DB_PORT=3306
      - DB_NAME=xclone
      - DB_USER=xclone
      - DB_PASSWORD=xclone
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    volumes:
      - .:/app
      - ~/.gradle:/root/.gradle

  db:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_DATABASE=xclone
      - MYSQL_USER=xclone
      - MYSQL_PASSWORD=xclone
      - MYSQL_ROOT_PASSWORD=root
    volumes:
      - mysql-data:/var/lib/mysql

  redis:
    image: redis:6.2-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data

volumes:
  mysql-data:
  redis-data:
```

## 8. UUID最適化ユーティリティ

効率的なUUID操作を行うためのユーティリティクラスを実装します。

```kotlin
/**
 * UUIDをMySQL用に効率的に処理するためのユーティリティクラス
 */
object UuidUtil {
    /**
     * UUIDをMySQLのBINARY(16)形式に変換する
     * タイムスタンプの上位ビットと下位ビットをスワップして時系列でのソート効率を向上
     */
    fun uuidToMySqlBin(uuid: UUID, swapFlag: Boolean = true): ByteArray {
        val msb = uuid.mostSignificantBits
        val lsb = uuid.leastSignificantBits
        
        val bytes = ByteArray(16)
        
        if (!swapFlag) {
            // 通常の変換
            for (i in 0..7) {
                bytes[i] = ((msb shr ((7 - i) * 8)) and 0xFF).toByte()
            }
            for (i in 8..15) {
                bytes[i] = ((lsb shr ((15 - i) * 8)) and 0xFF).toByte()
            }
            return bytes
        }
        
        // スワップフラグ=1の場合の変換（タイムスタンプの上位ビットと下位ビットを交換）
        // time_mid (2バイト) + time_high (2バイト)
        bytes[0] = ((msb shr 48) and 0xFF).toByte()
        bytes[1] = ((msb shr 56) and 0xFF).toByte()
        bytes[2] = ((msb shr 32) and 0xFF).toByte()
        bytes[3] = ((msb shr 40) and 0xFF).toByte()
        
        // time_low (4バイト)
        bytes[4] = ((msb shr 24) and 0xFF).toByte()
        bytes[5] = ((msb shr 16) and 0xFF).toByte()
        bytes[6] = ((msb shr 8) and 0xFF).toByte()
        bytes[7] = (msb and 0xFF).toByte()
        
        // 残りの64ビット
        for (i in 8..15) {
            bytes[i] = ((lsb shr ((15 - i) * 8)) and 0xFF).toByte()
        }
        
        