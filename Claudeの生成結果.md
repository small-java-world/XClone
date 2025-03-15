# X クローンアプリケーション設計書

## 1. 概要

本設計書では、Xのクローンアプリケーションをドメイン駆動設計（DDD）とクリーンアーキテクチャを用いて実装する方法を解説します。

## 2. アーキテクチャ概要

### クリーンアーキテクチャの実装

クリーンアーキテクチャでは以下のレイヤーで構成します：

1. **Entities**（エンティティ）: ビジネスのコアルールを含むドメインモデル
2. **Use Cases**（ユースケース）: アプリケーション固有のビジネスルール
3. **Interface Adapters**（インターフェースアダプタ）: 外部との連携部分
4. **Frameworks & Drivers**（フレームワークとドライバー）: 技術的な詳細

依存関係の方向は、常に内側（エンティティ）に向かう形で設計します。

### プロジェクト構造

```
src/
├── main/
│   ├── kotlin/
│   │   └── com/
│   │       └── example/
│   │           └── xclone/
│   │               ├── XCloneApplication.kt
│   │               ├── user/
│   │               │   ├── domain/
│   │               │   │   ├── model/
│   │               │   │   │   ├── User.kt
│   │               │   │   │   └── UserRepository.kt
│   │               │   │   └── service/
│   │               │   │       └── UserDomainService.kt
│   │               │   ├── application/
│   │               │   │   ├── port/
│   │               │   │   │   ├── in/
│   │               │   │   │   │   ├── CreateUserUseCase.kt
│   │               │   │   │   │   └── FindUserUseCase.kt
│   │               │   │   │   └── out/
│   │               │   │   │       └── UserPersistencePort.kt
│   │               │   │   ├── service/
│   │               │   │   │   ├── UserService.kt
│   │               │   │   │   └── dto/
│   │               │   │   │       ├── CreateUserCommand.kt
│   │               │   │   │       └── UserResponse.kt
│   │               │   ├── adapter/
│   │               │   │   ├── in/
│   │               │   │   │   └── web/
│   │               │   │   │       ├── UserController.kt
│   │               │   │   │       └── dto/
│   │               │   │   │           ├── CreateUserRequest.kt
│   │               │   │   │           └── UserResponseDto.kt
│   │               │   │   └── out/
│   │               │   │       └── persistence/
│   │               │   │           ├── UserPersistenceAdapter.kt
│   │               │   │           ├── UserRepository.kt
│   │               │   │           └── entity/
│   │               │   │               └── UserEntity.kt
│   │               ├── tweet/
│   │               │   ├── domain/
│   │               │   │   ├── model/
│   │               │   │   │   ├── Tweet.kt
│   │               │   │   │   └── TweetRepository.kt
│   │               │   │   └── service/
│   │               │   │       └── TweetDomainService.kt
│   │               │   ├── application/
│   │               │   │   ├── port/
│   │               │   │   │   ├── in/
│   │               │   │   │   │   ├── CreateTweetUseCase.kt
│   │               │   │   │   │   └── FindTweetUseCase.kt
│   │               │   │   │   └── out/
│   │               │   │   │       └── TweetPersistencePort.kt
│   │               │   │   ├── service/
│   │               │   │   │   ├── TweetService.kt
│   │               │   │   │   └── dto/
│   │               │   │   │       ├── CreateTweetCommand.kt
│   │               │   │   │       └── TweetResponse.kt
│   │               │   ├── adapter/
│   │               │   │   ├── in/
│   │               │   │   │   └── web/
│   │               │   │   │       ├── TweetController.kt
│   │               │   │   │       └── dto/
│   │               │   │   │           ├── CreateTweetRequest.kt
│   │               │   │   │           └── TweetResponseDto.kt
│   │               │   │   └── out/
│   │               │   │       └── persistence/
│   │               │   │           ├── TweetPersistenceAdapter.kt
│   │               │   │           ├── TweetRepository.kt
│   │               │   │           └── entity/
│   │               │   │               └── TweetEntity.kt
│   │               ├── timeline/
│   │               │   └── ...
│   │               ├── notification/
│   │               │   └── ...
│   │               ├── follow/
│   │               │   └── ...
│   │                                   ├── storage/
│   │               │   ├── domain/
│   │               │   │   └── model/
│   │               │   │       └── StorageFile.kt
│   │               │   ├── application/
│   │               │   │   ├── port/
│   │               │   │   │   ├── in/
│   │               │   │   │   │   ├── UploadFileUseCase.kt
│   │               │   │   │   │   └── GetFileUseCase.kt
│   │               │   │   │   └── out/
│   │               │   │   │       └── StoragePort.kt
│   │               │   │   └── service/
│   │               │   │       └── StorageService.kt
│   │               │   └── adapter/
│   │               │       └── out/
│   │               │           └── s3/
│   │               │               └── S3StorageAdapter.kt
│   │               └── common/
│   │                   ├── exception/
│   │                   │   ├── ApplicationException.kt
│   │                   │   └── BusinessException.kt
│   │                   └── config/
│   │                       ├── JooqConfig.kt
│   │                       ├── RedisConfig.kt
│   │                       └── S3Config.kt
│   ├── resources/
│   │   ├── application.yml
│   │   └── db/
│   │       └── migration/
│   │           ├── V1__create_users_table.sql
│   │           ├── V2__create_tweets_table.sql
│   │           └── V3__create_storage_files_table.sql
└── test/
    └── kotlin/
        └── com/
            └── example/
                └── xclone/
                    ├── user/
                    │   ├── domain/
                    │   │   └── model/
                    │   │       └── UserTest.kt
                    │   ├── application/
                    │   │   └── service/
                    │   │       └── UserServiceTest.kt
                    │   └── adapter/
                    │       ├── in/
                    │       │   └── web/
                    │       │       └── UserControllerTest.kt
                    │       └── out/
                    │           └── persistence/
                    │               └── UserPersistenceAdapterTest.kt
                    └── tweet/
                        └── ...
```

## 3. 主要ドメイン

### ユーザードメイン

ユーザー管理に関する機能を提供します。

#### ドメインモデル

```kotlin
// User.kt
package com.example.xclone.user.domain.model

data class UserId(val value: String)

class User private constructor(
    val id: UserId,
    val username: String,
    val displayName: String,
    val email: String,
    val bio: String?,
    val profileImageUrl: String?,
    val createdAt: Instant
) {
    // ファクトリーメソッド
    companion object {
        fun create(
            username: String,
            displayName: String,
            email: String,
            bio: String? = null,
            profileImageUrl: String? = null
        ): User {
            require(username.length >= 3) { "Username must be at least 3 characters" }
            require(email.contains("@")) { "Invalid email format" }
            
            return User(
                id = UserId(UUID.randomUUID().toString()),
                username = username,
                displayName = displayName,
                email = email,
                bio = bio,
                profileImageUrl = profileImageUrl,
                createdAt = Instant.now()
            )
        }
    }
    
    // ビジネスロジック
    fun updateProfile(displayName: String, bio: String?, profileImageUrl: String?): User {
        return copy(
            displayName = displayName,
            bio = bio,
            profileImageUrl = profileImageUrl
        )
    }
    
    private fun copy(
        id: UserId = this.id,
        username: String = this.username,
        displayName: String = this.displayName,
        email: String = this.email,
        bio: String? = this.bio,
        profileImageUrl: String? = this.profileImageUrl,
        createdAt: Instant = this.createdAt
    ): User {
        return User(id, username, displayName, email, bio, profileImageUrl, createdAt)
    }
}

// UserRepository.kt
package com.example.xclone.user.domain.model

interface UserRepository {
    fun save(user: User): User
    fun findById(id: UserId): User?
    fun findByUsername(username: String): User?
    fun findByEmail(email: String): User?
}
```

#### アプリケーションサービス

```kotlin
// CreateUserUseCase.kt
package com.example.xclone.user.application.port.`in`

interface CreateUserUseCase {
    fun createUser(command: CreateUserCommand): UserResponse
}

// CreateUserCommand.kt
package com.example.xclone.user.application.service.dto

data class CreateUserCommand(
    val username: String,
    val displayName: String,
    val email: String,
    val password: String,
    val bio: String? = null,
    val profileImageUrl: String? = null
)

// UserService.kt
package com.example.xclone.user.application.service

@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) : CreateUserUseCase, FindUserUseCase {

    override fun createUser(command: CreateUserCommand): UserResponse {
        // Eメールが既に使用されているか確認
        userRepository.findByEmail(command.email)?.let {
            throw UserAlreadyExistsException("Email already in use")
        }
        
        // ユーザー名が既に使用されているか確認
        userRepository.findByUsername(command.username)?.let {
            throw UserAlreadyExistsException("Username already taken")
        }
        
        // パスワードのハッシュ化
        val hashedPassword = passwordEncoder.encode(command.password)
        
        // ユーザーの作成
        val user = User.create(
            username = command.username,
            displayName = command.displayName,
            email = command.email,
            bio = command.bio,
            profileImageUrl = command.profileImageUrl
        )
        
        // 永続化
        val savedUser = userRepository.save(user)
        
        // レスポンスの作成
        return UserResponse(
            id = savedUser.id.value,
            username = savedUser.username,
            displayName = savedUser.displayName,
            email = savedUser.email,
            bio = savedUser.bio,
            profileImageUrl = savedUser.profileImageUrl,
            createdAt = savedUser.createdAt
        )
    }
    
    // 他のユースケース実装...
}
```

### ツイートドメイン

ツイートの投稿・取得に関する機能を提供します。

#### ドメインモデル

```kotlin
// Tweet.kt
package com.example.xclone.tweet.domain.model

import com.example.xclone.user.domain.model.UserId
import java.time.Instant
import java.util.UUID

data class TweetId(val value: String)

class Tweet private constructor(
    val id: TweetId,
    val content: String,
    val authorId: UserId,
    val mediaUrls: List<String>,
    val replyToId: TweetId?,
    val createdAt: Instant
) {
    companion object {
        private const val MAX_CONTENT_LENGTH = 280
        
        fun create(
            content: String,
            authorId: UserId,
            mediaUrls: List<String> = emptyList(),
            replyToId: TweetId? = null
        ): Tweet {
            require(content.isNotBlank()) { "Tweet content cannot be empty" }
            require(content.length <= MAX_CONTENT_LENGTH) { "Tweet content exceeds maximum length of $MAX_CONTENT_LENGTH characters" }
            
            return Tweet(
                id = TweetId(UUID.randomUUID().toString()),
                content = content,
                authorId = authorId,
                mediaUrls = mediaUrls,
                replyToId = replyToId,
                createdAt = Instant.now()
            )
        }
    }
}

// TweetRepository.kt
package com.example.xclone.tweet.domain.model

interface TweetRepository {
    fun save(tweet: Tweet): Tweet
    fun findById(id: TweetId): Tweet?
    fun findByAuthorId(authorId: UserId, limit: Int, offset: Int): List<Tweet>
    fun findReplies(tweetId: TweetId, limit: Int, offset: Int): List<Tweet>
}
```

#### アプリケーションサービス

```kotlin
// CreateTweetUseCase.kt
package com.example.xclone.tweet.application.port.`in`

interface CreateTweetUseCase {
    fun createTweet(command: CreateTweetCommand): TweetResponse
}

// CreateTweetCommand.kt
package com.example.xclone.tweet.application.service.dto

data class CreateTweetCommand(
    val content: String,
    val authorId: String,
    val mediaUrls: List<String> = emptyList(),
    val replyToId: String? = null
)

// TweetService.kt
package com.example.xclone.tweet.application.service

@Service
class TweetService(
    private val tweetRepository: TweetRepository,
    private val userRepository: UserRepository
) : CreateTweetUseCase, FindTweetUseCase {

    override fun createTweet(command: CreateTweetCommand): TweetResponse {
        val authorId = UserId(command.authorId)
        
        // ユーザーの存在確認
        userRepository.findById(authorId) ?: throw UserNotFoundException("User not found")
        
        // リプライ先ツイートの存在確認（リプライの場合）
        val replyToId = command.replyToId?.let { 
            val tweetId = TweetId(it)
            tweetRepository.findById(tweetId) ?: throw TweetNotFoundException("Reply to tweet not found")
            tweetId
        }
        
        // ツイートの作成
        val tweet = Tweet.create(
            content = command.content,
            authorId = authorId,
            mediaUrls = command.mediaUrls,
            replyToId = replyToId
        )
        
        // 永続化
        val savedTweet = tweetRepository.save(tweet)
        
        // レスポンスの作成
        return TweetResponse(
            id = savedTweet.id.value,
            content = savedTweet.content,
            authorId = savedTweet.authorId.value,
            mediaUrls = savedTweet.mediaUrls,
            replyToId = savedTweet.replyToId?.value,
            createdAt = savedTweet.createdAt
        )
    }
    
    // 他のユースケース実装...
}
```

### フォロードメイン

フォロー関係を管理するドメインです。

```kotlin
// Follow.kt
package com.example.xclone.follow.domain.model

import com.example.xclone.user.domain.model.UserId
import java.time.Instant

class Follow private constructor(
    val followerId: UserId,
    val followedId: UserId,
    val createdAt: Instant
) {
    companion object {
        fun create(followerId: UserId, followedId: UserId): Follow {
            require(followerId != followedId) { "User cannot follow themselves" }
            
            return Follow(
                followerId = followerId,
                followedId = followedId,
                createdAt = Instant.now()
            )
        }
    }
}
```

### タイムラインドメイン

タイムライン表示に関する機能を提供します。このドメインはユーザーとツイートドメインに依存します。

```kotlin
// TimelineService.kt
package com.example.xclone.timeline.application.service

@Service
class TimelineService(
    private val tweetRepository: TweetRepository,
    private val followRepository: FollowRepository,
    private val userRepository: UserRepository,
    private val redisTemplate: RedisTemplate<String, Any>
) : GetHomeTimelineUseCase {

    override fun getHomeTimeline(command: GetHomeTimelineCommand): TimelineResponse {
        val userId = UserId(command.userId)
        
        // キャッシュからタイムラインを取得
        val cacheKey = "timeline:${userId.value}"
        val cachedTimeline = redisTemplate.opsForValue().get(cacheKey) as? List<TweetResponse>
        
        if (cachedTimeline != null) {
            return TimelineResponse(tweets = cachedTimeline)
        }
        
        // ユーザーがフォローしているユーザーのIDを取得
        val followedUserIds = followRepository.findFollowedByUserId(userId)
            .map { it.followedId }
            
        // 自分のIDも含める（自分のツイートもタイムラインに表示）
        val allUserIds = followedUserIds + userId
        
        // ツイートを取得（最新順）
        val tweets = tweetRepository.findByAuthorIdIn(
            authorIds = allUserIds,
            limit = command.limit,
            offset = command.offset
        )
        
        // ツイートレスポンスの作成
        val tweetResponses = tweets.map { tweet ->
            val author = userRepository.findById(tweet.authorId)!!
            TweetResponse(
                id = tweet.id.value,
                content = tweet.content,
                authorId = tweet.authorId.value,
                authorUsername = author.username,
                authorDisplayName = author.displayName,
                authorProfileImageUrl = author.profileImageUrl,
                mediaUrls = tweet.mediaUrls,
                replyToId = tweet.replyToId?.value,
                createdAt = tweet.createdAt
            )
        }
        
        // キャッシュに保存（5分間有効）
        redisTemplate.opsForValue().set(cacheKey, tweetResponses, Duration.ofMinutes(5))
        
        return TimelineResponse(tweets = tweetResponses)
    }
}
```

## 4. データベース設計

### ER図

```
+--------------+       +--------------+       +--------------+
|    users     |       |    tweets    |       |   follows    |
+--------------+       +--------------+       +--------------+
| id (PK)      |       | id (PK)      |       | follower_id  |
| username     |  1    | content      |       | followed_id  |
| display_name |<------| author_id(FK)|       | created_at   |
| email        |       | reply_to_id  |       +--------------+
| password     |       | created_at   |              ^
| bio          |       +--------------+              |
| profile_img  |              ^                      |
| created_at   |              |                      |
+--------------+              |                      |
      ^                       |                      |
      |                       |                      |
      +-------------------+---+----------------------+
                          |
                   +--------------+
                   | tweet_media  |
                   +--------------+
                   | id (PK)      |
                   | tweet_id(FK) |
                   | media_url    |
                   | created_at   |
                   +--------------+
```

### DDLスクリプト

```sql
-- V1__create_users_table.sql
CREATE TABLE users (
    id VARCHAR(36) PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    bio TEXT,
    profile_image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
);

-- V2__create_tweets_table.sql
CREATE TABLE tweets (
    id VARCHAR(36) PRIMARY KEY,
    content VARCHAR(280) NOT NULL,
    author_id VARCHAR(36) NOT NULL,
    reply_to_id VARCHAR(36),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id),
    FOREIGN KEY (reply_to_id) REFERENCES tweets(id),
    INDEX idx_author_id (author_id),
    INDEX idx_reply_to_id (reply_to_id),
    INDEX idx_created_at (created_at)
);

-- V3__create_tweet_media_table.sql
CREATE TABLE tweet_media (
    id VARCHAR(36) PRIMARY KEY,
    tweet_id VARCHAR(36) NOT NULL,
    storage_file_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE,
    FOREIGN KEY (storage_file_id) REFERENCES storage_files(id),
    INDEX idx_tweet_id (tweet_id)
);

-- V5__create_storage_files_table.sql
CREATE TABLE storage_files (
    id VARCHAR(36) PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(100) NOT NULL,
    size BIGINT NOT NULL,
    path VARCHAR(512) NOT NULL,
    url VARCHAR(512) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_path (path)
);

-- V4__create_follows_table.sql
CREATE TABLE follows (
    follower_id VARCHAR(36) NOT NULL,
    followed_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (follower_id, followed_id),
    FOREIGN KEY (follower_id) REFERENCES users(id),
    FOREIGN KEY (followed_id) REFERENCES users(id),
    INDEX idx_follower_id (follower_id),
    INDEX idx_followed_id (followed_id)
);
```

## 5. ストレージサービスの実装

```kotlin
// StorageFile.kt
package com.example.xclone.storage.domain.model

import java.time.Instant
import java.util.UUID

data class StorageFileId(val value: String)

class StorageFile private constructor(
    val id: StorageFileId,
    val filename: String,
    val contentType: String,
    val size: Long,
    val path: String,
    val url: String,
    val createdAt: Instant
) {
    companion object {
        fun create(
            filename: String,
            contentType: String,
            size: Long,
            bucketName: String
        ): StorageFile {
            val id = UUID.randomUUID().toString()
            val path = "${bucketName}/${id}_${filename}"
            
            return StorageFile(
                id = StorageFileId(id),
                filename = filename,
                contentType = contentType,
                size = size,
                path = path,
                url = "/api/files/${path}",
                createdAt = Instant.now()
            )
        }
    }
}

// StoragePort.kt
package com.example.xclone.storage.application.port.out

import com.example.xclone.storage.domain.model.StorageFile
import java.io.InputStream

interface StoragePort {
    fun uploadFile(file: StorageFile, content: InputStream): StorageFile
    fun getFileContent(file: StorageFile): InputStream
    fun deleteFile(file: StorageFile)
}

// S3StorageAdapter.kt
package com.example.xclone.storage.adapter.out.s3

import com.example.xclone.storage.application.port.out.StoragePort
import com.example.xclone.storage.domain.model.StorageFile
import org.springframework.stereotype.Component
import software.amazon.awssdk.core.sync.RequestBody
import software.amazon.awssdk.services.s3.S3Client
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest
import software.amazon.awssdk.services.s3.model.GetObjectRequest
import software.amazon.awssdk.services.s3.model.PutObjectRequest
import java.io.InputStream

@Component
class S3StorageAdapter(private val s3Client: S3Client) : StoragePort {

    override fun uploadFile(file: StorageFile, content: InputStream): StorageFile {
        val request = PutObjectRequest.builder()
            .bucket(getBucketFromPath(file.path))
            .key(getKeyFromPath(file.path))
            .contentType(file.contentType)
            .build()
            
        s3Client.putObject(request, RequestBody.fromInputStream(content, file.size))
        
        return file
    }

    override fun getFileContent(file: StorageFile): InputStream {
        val request = GetObjectRequest.builder()
            .bucket(getBucketFromPath(file.path))
            .key(getKeyFromPath(file.path))
            .build()
            
        val response = s3Client.getObject(request)
        
        return response
    }

    override fun deleteFile(file: StorageFile) {
        val request = DeleteObjectRequest.builder()
            .bucket(getBucketFromPath(file.path))
            .key(getKeyFromPath(file.path))
            .build()
            
        s3Client.deleteObject(request)
    }
    
    private fun getBucketFromPath(path: String): String {
        return path.substringBefore("/")
    }
    
    private fun getKeyFromPath(path: String): String {
        return path.substringAfter("/")
    }
}

// S3Config.kt
package com.example.xclone.common.config

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider
import software.amazon.awssdk.regions.Region
import software.amazon.awssdk.services.s3.S3Client
import java.net.URI

@Configuration
class S3Config {

    @Value("\${app.storage.s3.endpoint}")
    private lateinit var endpoint: String
    
    @Value("\${app.storage.s3.region}")
    private lateinit var region: String
    
    @Value("\${app.storage.s3.access-key}")
    private lateinit var accessKey: String
    
    @Value("\${app.storage.s3.secret-key}")
    private lateinit var secretKey: String
    
    @Bean
    fun s3Client(): S3Client {
        val credentials = AwsBasicCredentials.create(accessKey, secretKey)
        
        return S3Client.builder()
            .endpointOverride(URI.create(endpoint))
            .region(Region.of(region))
            .credentialsProvider(StaticCredentialsProvider.create(credentials))
            .build()
    }
}
```

## 6. 永続化レイヤーの実装（jOOQ）

```kotlin
// UserPersistenceAdapter.kt
package com.example.xclone.user.adapter.out.persistence

@Repository
class UserPersistenceAdapter(
    private val dsl: DSLContext,
    private val userEntityMapper: UserEntityMapper
) : UserPersistencePort {

    override fun save(user: User): User {
        val userEntity = userEntityMapper.toEntity(user)
        
        // 新規作成の場合
        if (findById(user.id) == null) {
            dsl.insertInto(USERS)
                .set(USERS.ID, userEntity.id)
                .set(USERS.USERNAME, userEntity.username)
                .set(USERS.DISPLAY_NAME, userEntity.displayName)
                .set(USERS.EMAIL, userEntity.email)
                .set(USERS.PASSWORD_HASH, userEntity.passwordHash)
                .set(USERS.BIO, userEntity.bio)
                .set(USERS.PROFILE_IMAGE_URL, userEntity.profileImageUrl)
                .set(USERS.CREATED_AT, userEntity.createdAt)
                .execute()
        } 
        // 更新の場合
        else {
            dsl.update(USERS)
                .set(USERS.DISPLAY_NAME, userEntity.displayName)
                .set(USERS.BIO, userEntity.bio)
                .set(USERS.PROFILE_IMAGE_URL, userEntity.profileImageUrl)
                .where(USERS.ID.eq(userEntity.id))
                .execute()
        }
        
        return user
    }

    override fun findById(id: UserId): User? {
        return dsl.selectFrom(USERS)
            .where(USERS.ID.eq(id.value))
            .fetchOne()
            ?.let { userEntityMapper.toDomain(it) }
    }

    override fun findByUsername(username: String): User? {
        return dsl.selectFrom(USERS)
            .where(USERS.USERNAME.eq(username))
            .fetchOne()
            ?.let { userEntityMapper.toDomain(it) }
    }

    override fun findByEmail(email: String): User? {
        return dsl.selectFrom(USERS)
            .where(USERS.EMAIL.eq(email))
            .fetchOne()
            ?.let { userEntityMapper.toDomain(it) }
    }
}
```

## 6. APIレイヤーの実装

```kotlin
// UserController.kt
package com.example.xclone.user.adapter.in.web

@RestController
@RequestMapping("/api/users")
class UserController(
    private val createUserUseCase: CreateUserUseCase,
    private val findUserUseCase: FindUserUseCase
) {

    @PostMapping
    fun createUser(@RequestBody request: CreateUserRequest): ResponseEntity<UserResponseDto> {
        val command = CreateUserCommand(
            username = request.username,
            displayName = request.displayName,
            email = request.email,
            password = request.password,
            bio = request.bio,
            profileImageUrl = request.profileImageUrl
        )
        
        val userResponse = createUserUseCase.createUser(command)
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(UserResponseDto.fromDomain(userResponse))
    }
    
    @GetMapping("/{id}")
    fun getUserById(@PathVariable id: String): ResponseEntity<UserResponseDto> {
        val command = FindUserByIdCommand(id)
        val userResponse = findUserUseCase.findUserById(command)
        
        return ResponseEntity.ok(UserResponseDto.fromDomain(userResponse))
    }
    
    @GetMapping("/username/{username}")
    fun getUserByUsername(@PathVariable username: String): ResponseEntity<UserResponseDto> {
        val command = FindUserByUsernameCommand(username)
        val userResponse = findUserUseCase.findUserByUsername(command)
        
        return ResponseEntity.ok(UserResponseDto.fromDomain(userResponse))
    }
    
    // 他のエンドポイント...
}
```

## 7. フロントエンド（Next.js）の構成

```
frontend/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── auth/
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── signup/
│   │       └── page.tsx
│   ├── [username]/
│   │   ├── page.tsx
│   │   └── status/
│   │       └── [id]/
│   │           └── page.tsx
│   └── home/
│       └── page.tsx
├── components/
│   ├── layout/
│   │   ├── Header.tsx
│   │   └── Sidebar.tsx
│   ├── tweet/
│   │   ├── TweetCard.tsx
│   │   └── TweetForm.tsx
│   ├── profile/
│   │   ├── ProfileHeader.tsx
│   │   └── ProfileTabs.tsx
│   └── ui/
│       ├── Button.tsx
│       └── Input.tsx
├── lib/
│   ├── api.ts
│   └── hooks/
│       ├── useAuth.ts
│       └── useTweets.ts
└── next.config.js
```

## 8. Docker Compose設定

```yaml
# docker-compose.yml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      - mysql
      - redis
      - minio
    environment:
      - SPRING_PROFILES_ACTIVE=local
      - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/xclone?useSSL=false
      - SPRING_DATASOURCE_USERNAME=root
      - SPRING_DATASOURCE_PASSWORD=password
      - SPRING_REDIS_HOST=redis
      - SPRING_REDIS_PORT=6379
      - APP_STORAGE_S3_ENDPOINT=http://minio:9000
      - APP_STORAGE_S3_REGION=us-east-1
      - APP_STORAGE_S3_ACCESS_KEY=minioadmin
      - APP_STORAGE_S3_SECRET_KEY=minioadmin
    volumes:
      - ./.env.local:/app/.env.local

  mysql:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_DATABASE=xclone
      - MYSQL_ROOT_PASSWORD=password
    volumes:
      - mysql-data:/var/lib/mysql

  redis:
    image: redis:7.0
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
      
  minio:
    image: minio/minio:latest
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=minioadmin
    volumes:
      - minio-data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3

  createbuckets:
    image: minio/mc
    depends_on:
      - minio
    entrypoint: >
      /bin/sh -c "
      sleep 5;
      /usr/bin/mc config host add myminio http://minio:9000 minioadmin minioadmin;
      /usr/bin/mc mb myminio/xclone-media;
      /usr/bin/mc mb myminio/xclone-avatars;
      /usr/bin/mc policy set public myminio/xclone-media;
      /usr/bin/mc policy set public myminio/xclone-avatars;
      exit 0;
      "

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules

volumes:
  mysql-data:
  redis-data:
  minio-data:
```

## 9. TDDアプローチ

テスト駆動開発（TDD）を実践するために、以下の順序で開発を進めます：

1. ドメインモデルのテスト作成・実装
2. アプリケーションサービスのテスト作成・実装
3. アダプターレイヤーのテスト作成・実装
4. 各レイヤーの統合

```kotlin
// UserTest.kt
package com.example.xclone.user.domain.model

import io.kotest.assertions.throwables.shouldThrow
import io.kotest.core.spec.style.FunSpec
import io.kotest.matchers.shouldBe
import io.kotest.matchers.shouldNotBe

class UserTest : FunSpec({
    
    test("正常にユーザーが作成できること") {
        val user = User.create(
            username = "testuser",
            displayName = "Test User",
            email = "test@example.com",
            bio = "My bio",
            profileImageUrl = "http://example.com/image.jpg"
        )
        
        user.id shouldNotBe null
        user.username shouldBe "testuser"
        user.displayName shouldBe "Test User"
        user.email shouldBe "test@example.com"
        user.bio shouldBe "My bio"
        user.profileImageUrl shouldBe "http://example.com/image.jpg"
    }
    
    test("ユーザー名が3文字未満の場合、例外がスローされること") {
        shouldThrow<IllegalArgumentException> {
            User.create(
                username = "ab", // 2文字
                displayName = "Test User",
                email = "test@example.com"
            )
        }
    }
    
    test("無効なメールフォーマットの場合、例外がスローされること") {
        shouldThrow<IllegalArgumentException> {
            User.create(
                username = "testuser",
                displayName = "Test User",
                email = "invalid-email" // @記号がない
            )
        }
    }
    
    test("プロフィール更新が正常に機能すること") {
        val user = User.create(
            username = "testuser",
            displayName = "Test User",
            email = "test@example.com"
        )
        
        val updatedUser = user.updateProfile(
            displayName = "Updated Name",
            bio = "Updated bio",
            profileImageUrl = "http://example.com/updated.jpg"
        )
        
        updatedUser.displayName shouldBe "Updated Name"
        updatedUser.bio shouldBe "Updated bio"
        updatedUser.profileImageUrl shouldBe "http://example.com/updated.jpg"
        
        // 変更されないフィールドの確認
        updatedUser.id shouldBe user.id
        updatedUser.username shouldBe user.username
        updatedUser.email shouldBe user.email
    }
})
```

## 10. AI駆動開発の実装戦略

Cursor AIエージェントを使用して効率的に開発するためのアプローチ：

1. 最初にドメインモデルとテストケースを実装
2. ユースケースとアプリケーションサービスの実装
3. 永続化アダプターの実装
4. Webアダプターの実装
5. フロントエンド実装とAPI統合

各ステップで、AIエージェントに以下の指示を与えます：

```
指示例：
TDDアプローチでXクローンアプリの[コンポーネント名]を実装してください。
- DDDとクリーンアーキテクチャの原則に従ってください
- Kotlinを使用し、Spring Bootフレームワーク上に実装してください
- 以下の要件を満たすコードを生成してください：
  [要件リスト]
- テストケースも含めてください（Kotestを使用）
```

## 11. ファイルアップロード機能の実装例

ツイートに画像を添付する機能の実装例を示します：

```kotlin
// TweetController.kt（一部抜粋）
@RestController
@RequestMapping("/api/tweets")
class TweetController(
    private val createTweetUseCase: CreateTweetUseCase,
    private val uploadFileUseCase: UploadFileUseCase
) {

    @PostMapping(consumes = [MediaType.MULTIPART_FORM_DATA_VALUE])
    fun createTweetWithMedia(
        @RequestPart("tweet") request: CreateTweetRequest,
        @RequestPart("media", required = false) mediaFiles: List<MultipartFile>?
    ): ResponseEntity<TweetResponseDto> {
        
        // メディアファイルのアップロード処理
        val mediaUrls = mediaFiles?.map { file ->
            val uploadCommand = UploadFileCommand(
                filename = file.originalFilename ?: "unknown.jpg",
                contentType = file.contentType ?: "application/octet-stream",
                size = file.size,
                content = file.inputStream,
                bucketName = "xclone-media"
            )
            
            uploadFileUseCase.uploadFile(uploadCommand)
        } ?: emptyList()
        
        // ツイートの作成
        val command = CreateTweetCommand(
            content = request.content,
            authorId = request.authorId,
            mediaUrls = mediaUrls.map { it.url },
            replyToId = request.replyToId
        )
        
        val tweetResponse = createTweetUseCase.createTweet(command)
        
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(TweetResponseDto.fromDomain(tweetResponse))
    }
}
```

## 12. まとめ

本設計書では、DDDとクリーンアーキテクチャを用いたXクローンアプリケーションの設計について詳細に解説しました。強固なドメイン境界を持ち、単一責務の原則に従ったユースケース設計と、テスト駆動開発やAI駆動開発を組み合わせたアプローチにより、保守性の高い高品質なアプリケーションを効率的に開発できます。

各ドメイン（ユーザー、ツイート、フォロー、タイムライン、ストレージなど）は明確に分離され、それぞれのドメイン内では依存関係の方向が内側に向かうように設計されています。また、環境変数の活用やDockerを用いた開発環境の整備により、開発者体験も向上しています。

S3互換ストレージであるMinioを採用することで、ユーザープロフィール画像やツイートに添付するメディアファイルを効率的に管理でき、かつローカル開発環境でもクラウド環境と同様の実装が可能となっています。

主キーにはUUID v7を採用することで、以下の利点があります：

1. **時間的ソート可能性**: UUID v7はタイムスタンプを含むため、生成順に自然とソートされます。これにより、時系列データの効率的な取得が可能になります。

2. **グローバルな一意性**: 分散システムでも衝突リスクが極めて低く、シャーディングやレプリケーションを行う際にも安全です。

3. **予測不可能性**: セキュリティの観点から、IDの予測が困難であるため、列挙攻撃のリスクを低減します。

4. **パフォーマンス**: インデックスの効率が良く、データベースのパフォーマンスを最適化できます。

5. **移行の容易さ**: 既存のUUID型のカラムをそのまま使用できるため、データベースの移行が容易です。