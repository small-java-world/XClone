# LINEクローンアプリ開発：DDDとクリーンアーキテクチャの実践

## はじめに

この記事では、社内プロジェクトとして開発したLINEクローンアプリの設計と実装について解説します。本プロジェクトでは、ドメイン駆動設計（DDD）とクリーンアーキテクチャを採用し、堅牢で保守性の高いアプリケーション開発を目指しました。また、開発プロセスにおいてAI駆動開発とTDDを取り入れた結果についても共有します。

## 技術スタック概要

本プロジェクトで採用した技術スタックは以下の通りです：

### バックエンド
- Kotlin + Spring Boot (Java 21)
- ユニットテスト: Kotest + Mockk
- ORM: jOOQ
- データベース: MySQL + Redis(キャッシュ)
- ストレージ: MinIO (S3互換)

### フロントエンド
- Next.js
- ユニットテスト: Vitest
- E2Eテスト: Playwright

### 開発環境
- Docker Compose

## ドメイン駆動設計(DDD)とクリーンアーキテクチャ

### DDDのコアコンセプト

ドメイン駆動設計では、ビジネスロジックとドメインモデルを中心に据えた設計アプローチを取ります。本プロジェクトでは以下の要素を重視しました：

- **ユビキタス言語**: チーム内での共通言語の確立
- **境界づけられたコンテキスト**: 明確なドメイン境界の設定
- **エンティティと値オブジェクト**: ドメインオブジェクトの適切な設計
- **集約**: データの一貫性を保つための集約設計
- **リポジトリ**: 永続化のための抽象化

### クリーンアーキテクチャの層構造

クリーンアーキテクチャでは、依存関係の方向を内側（ドメイン）に向ける設計を採用しています。本プロジェクトでは以下の4層構造を実装しました：

1. **エンティティ層（ドメイン層）**
   - ビジネスルールとドメインモデルを含む
   - 外部の具体的な実装に依存しない

2. **ユースケース層（アプリケーション層）**
   - アプリケーションの具体的なユースケースを実装
   - ドメイン層のみに依存

3. **インターフェースアダプター層**
   - コントローラー、プレゼンター、ゲートウェイなどの実装
   - 内側の層と外側の層の橋渡し役

4. **フレームワーク・ドライバー層**
   - データベース、UI、外部APIなどの具体的な実装
   - 外部ライブラリやフレームワークへの依存を集約

## 詳細なプロジェクト構造

DDDとクリーンアーキテクチャの原則に基づき、以下の詳細なプロジェクト構造を採用しました：

```
lineclone/
├── build.gradle.kts             # Gradleビルドスクリプト
├── settings.gradle.kts          # Gradle設定ファイル
├── gradlew                      # Gradleラッパースクリプト
├── gradlew.bat                  # Windows用Gradleラッパースクリプト
├── gradle/                      # Gradleラッパー設定
├── build/                       # ビルド出力ディレクトリ
│   └── generated-sources/       # 生成されたソースコード
│       └── jooq/                # jOOQ生成コード
│           └── com/example/lineclone/infrastructure/jooq/
│               ├── tables/      # 自動生成されるテーブル定義
│               └── records/     # 自動生成されるレコード定義
├── .env.local                   # ローカル環境変数
├── docker-compose.yml           # Docker Compose設定
├── docker/                      # Dockerリソース
│   ├── mysql/
│   │   └── init/                # MySQLの初期化スクリプト
│   ├── api/
│   │   └── Dockerfile           # APIサーバーのDockerfile
│   └── web/
│       └── Dockerfile           # Webフロントエンドのフロントエンド
├── src/
│   ├── main/
│   │   ├── kotlin/com/example/lineclone/
│   │   │   ├── LineCloneApplication.kt           # アプリケーションエントリーポイント
│   │   │   ├── common/                           # 共通コンポーネント
│   │   │   │   ├── config/                       # 共通設定
│   │   │   │   │   ├── SecurityConfig.kt         # セキュリティ設定
│   │   │   │   │   ├── RedisConfig.kt            # Redis設定
│   │   │   │   │   ├── S3Config.kt               # S3設定
│   │   │   │   │   └── EnvironmentConfig.kt      # 環境変数設定
│   │   │   │   ├── exception/                    # 例外処理
│   │   │   │   │   ├── GlobalExceptionHandler.kt # グローバル例外ハンドラー
│   │   │   │   │   ├── ApiError.kt               # API エラーレスポンス
│   │   │   │   │   ├── BusinessException.kt      # ビジネス例外
│   │   │   │   │   └── ResourceNotFoundException.kt # リソース未検出例外
│   │   │   │   ├── util/                         # ユーティリティ
│   │   │   │   │   ├── JwtUtil.kt                # JWT ユーティリティ
│   │   │   │   │   └── DateTimeUtil.kt           # 日時ユーティリティ
│   │   │   │   └── middleware/                   # ミドルウェア
│   │   │   │       ├── AuthMiddleware.kt         # 認証ミドルウェア
│   │   │   │       └── LoggingMiddleware.kt      # ロギングミドルウェア
│   │   │   │
│   │   │   ├── auth/                             # 認証ドメイン境界
│   │   │   │   ├── domain/                       # 認証ドメイン層
│   │   │   │   │   ├── entity/
│   │   │   │   │   │   └── User.kt               # ユーザーエンティティ（認証コンテキスト）
│   │   │   │   │   ├── vo/                       # 値オブジェクト
│   │   │   │   │   │   ├── Email.kt
│   │   │   │   │   │   ├── Password.kt
│   │   │   │   │   │   └── Token.kt
│   │   │   │   │   ├── repository/               # リポジトリインターフェース
│   │   │   │   │   │   └── UserRepository.kt     # ユーザーリポジトリインターフェース
│   │   │   │   │   └── service/                  # ドメインサービス
│   │   │   │   │       └── AuthService.kt        # 認証サービス
│   │   │   │   ├── application/                  # 認証アプリケーション層
│   │   │   │   │   ├── SignUpUseCase.kt          # サインアップユースケース
│   │   │   │   │   ├── SignInUseCase.kt          # サインインユースケース
│   │   │   │   │   ├── SignOutUseCase.kt         # サインアウトユースケース
│   │   │   │   │   ├── RefreshTokenUseCase.kt    # トークンリフレッシュユースケース
│   │   │   │   │   └── dto/                      # DTOクラス
│   │   │   │   │       ├── SignUpCommand.kt
│   │   │   │   │       ├── SignInCommand.kt
│   │   │   │   │       └── AuthResult.kt
│   │   │   │   ├── infrastructure/               # 認証インフラストラクチャ層
│   │   │   │   │   ├── JooqUserRepository.kt     # jOOQを使用したユーザーリポジトリ実装
│   │   │   │   │   └── JwtTokenProvider.kt       # JWTトークンプロバイダ実装
│   │   │   │   └── presentation/                 # 認証プレゼンテーション層
│   │   │   │       ├── AuthController.kt         # 認証コントローラー
│   │   │   │       └── dto/
│   │   │   │           ├── request/
│   │   │   │           │   └── AuthRequest.kt
│   │   │   │           └── response/
│   │   │   │               └── AuthResponse.kt
│   │   │   │
│   │   │   ├── user/                             # ユーザードメイン境界
│   │   │   │   ├── domain/                       # ユーザードメイン層
│   │   │   │   │   ├── entity/                   
│   │   │   │   │   │   ├── Profile.kt            # プロフィールエンティティ
│   │   │   │   │   │   └── Friend.kt             # 友達エンティティ
│   │   │   │   │   ├── vo/                      
│   │   │   │   │   │   ├── UserId.kt             # ユーザーID値オブジェクト
│   │   │   │   │   │   ├── ProfileId.kt          # プロフィールID値オブジェクト
│   │   │   │   │   │   ├── DisplayName.kt        # 表示名値オブジェクト
│   │   │   │   │   │   └── StatusMessage.kt      # ステータスメッセージ値オブジェクト
│   │   │   │   │   ├── repository/              
│   │   │   │   │   │   ├── ProfileRepository.kt  # プロフィールリポジトリ
│   │   │   │   │   │   └── FriendRepository.kt   # 友達リポジトリ
│   │   │   │   │   └── service/                 
│   │   │   │   │       └── FriendService.kt      # 友達サービス
│   │   │   │   ├── application/                  # ユーザーアプリケーション層
│   │   │   │   │   ├── GetUserProfileUseCase.kt  # ユーザープロフィール取得ユースケース
│   │   │   │   │   ├── UpdateProfileUseCase.kt   # プロフィール更新ユースケース
│   │   │   │   │   ├── AddFriendUseCase.kt       # 友達追加ユースケース
│   │   │   │   │   ├── GetFriendListUseCase.kt   # 友達リスト取得ユースケース
│   │   │   │   │   └── dto/
│   │   │   │   │       ├── ProfileCommand.kt
│   │   │   │   │       ├── ProfileResult.kt
│   │   │   │   │       ├── FriendCommand.kt
│   │   │   │   │       └── FriendResult.kt
│   │   │   │   ├── infrastructure/               # ユーザーインフラストラクチャ層
│   │   │   │   │   ├── JooqProfileRepository.kt  # jOOQを使用したプロフィールリポジトリ実装
│   │   │   │   │   └── JooqFriendRepository.kt   # jOOQを使用した友達リポジトリ実装
│   │   │   │   └── presentation/                 # ユーザープレゼンテーション層
│   │   │   │       ├── UserController.kt         # ユーザーコントローラー
│   │   │   │       └── dto/
│   │   │   │           ├── request/
│   │   │   │           │   └── UserRequest.kt
│   │   │   │           └── response/
│   │   │   │               └── UserResponse.kt
│   │   │   │
│   │   │   ├── chat/                             # チャットドメイン境界
│   │   │   │   ├── domain/                       # チャットドメイン層
│   │   │   │   │   ├── entity/                  
│   │   │   │   │   │   ├── Message.kt            # メッセージエンティティ
│   │   │   │   │   │   ├── ChatRoom.kt           # チャットルームエンティティ
│   │   │   │   │   │   └── ChatMember.kt         # チャットメンバーエンティティ
│   │   │   │   │   ├── vo/                      
│   │   │   │   │   │   ├── MessageId.kt          # メッセージID値オブジェクト
│   │   │   │   │   │   ├── MessageContent.kt     # メッセージ内容値オブジェクト
│   │   │   │   │   │   ├── ChatRoomId.kt         # チャットルームID値オブジェクト
│   │   │   │   │   │   └── ChatRoomType.kt       # チャットルームタイプ値オブジェクト
│   │   │   │   │   ├── repository/              
│   │   │   │   │   │   ├── MessageRepository.kt  # メッセージリポジトリ
│   │   │   │   │   │   ├── ChatRoomRepository.kt # チャットルームリポジトリ
│   │   │   │   │   │   └── ChatMemberRepository.kt # チャットメンバーリポジトリ
│   │   │   │   │   └── service/                 
│   │   │   │   │       ├── MessageDomainService.kt # メッセージドメインサービス
│   │   │   │   │       └── ChatRoomDomainService.kt # チャットルームドメインサービス
│   │   │   │   ├── application/                  # チャットアプリケーション層
│   │   │   │   │   ├── CreateChatRoomUseCase.kt  # チャットルーム作成ユースケース
│   │   │   │   │   ├── GetChatRoomListUseCase.kt # チャットルームリスト取得ユースケース
│   │   │   │   │   ├── SendMessageUseCase.kt     # メッセージ送信ユースケース
│   │   │   │   │   ├── GetMessagesUseCase.kt     # メッセージ取得ユースケース
│   │   │   │   │   ├── MarkAsReadUseCase.kt      # 既読マークユースケース
│   │   │   │   │   └── dto/
│   │   │   │   │       ├── ChatRoomCommand.kt
│   │   │   │   │       ├── ChatRoomResult.kt
│   │   │   │   │       ├── MessageCommand.kt
│   │   │   │   │       └── MessageResult.kt
│   │   │   │   ├── infrastructure/               # チャットインフラストラクチャ層
│   │   │   │   │   ├── JooqMessageRepository.kt  # jOOQを使用したメッセージリポジトリ実装
│   │   │   │   │   ├── JooqChatRoomRepository.kt # jOOQを使用したチャットルームリポジトリ実装
│   │   │   │   │   ├── JooqChatMemberRepository.kt # jOOQを使用したチャットメンバーリポジトリ実装
│   │   │   │   │   └── RedisMessageCache.kt      # Redisを使用したメッセージキャッシュ実装
│   │   │   │   └── presentation/                 # チャットプレゼンテーション層
│   │   │   │       ├── ChatController.kt         # チャットコントローラー
│   │   │   │       ├── websocket/
│   │   │   │       │   └── ChatWebSocketHandler.kt # チャットWebSocketハンドラ
│   │   │   │       └── dto/
│   │   │   │           ├── request/
│   │   │   │           │   └── ChatRequest.kt
│   │   │   │           └── response/
│   │   │   │               └── ChatResponse.kt
│   │   │   │
│   │   │   ├── notification/                     # 通知ドメイン境界
│   │   │   │   ├── domain/                       # 通知ドメイン層
│   │   │   │   │   ├── entity/                  
│   │   │   │   │   │   ├── Notification.kt       # 通知エンティティ
│   │   │   │   │   │   └── DeviceToken.kt        # デバイストークンエンティティ
│   │   │   │   │   ├── vo/                      
│   │   │   │   │   │   ├── NotificationId.kt     # 通知ID値オブジェクト
│   │   │   │   │   │   └── NotificationType.kt   # 通知タイプ値オブジェクト
│   │   │   │   │   ├── repository/              
│   │   │   │   │   │   ├── NotificationRepository.kt # 通知リポジトリ
│   │   │   │   │   │   └── DeviceTokenRepository.kt # デバイストークンリポジトリ
│   │   │   │   │   └── service/                 
│   │   │   │   │       └── NotificationService.kt # 通知サービス
│   │   │   │   ├── application/                  # 通知アプリケーション層
│   │   │   │   │   ├── RegisterDeviceTokenUseCase.kt # デバイストークン登録ユースケース
│   │   │   │   │   ├── SendNotificationUseCase.kt   # 通知送信ユースケース
│   │   │   │   │   ├── GetNotificationsUseCase.kt   # 通知取得ユースケース
│   │   │   │   │   └── dto/
│   │   │   │   │       ├── NotificationCommand.kt
│   │   │   │   │       ├── NotificationResult.kt
│   │   │   │   │       ├── DeviceTokenCommand.kt
│   │   │   │   │       └── DeviceTokenResult.kt
│   │   │   │   ├── infrastructure/               # 通知インフラストラクチャ層
│   │   │   │   │   ├── JooqNotificationRepository.kt  # jOOQを使用した通知リポジトリ実装
│   │   │   │   │   ├── JooqDeviceTokenRepository.kt  # jOOQを使用したデバイストークンリポジトリ実装
│   │   │   │   │   └── FirebasePushNotificationService.kt # Firebaseプッシュ通知サービス実装
│   │   │   │   └── presentation/                 # 通知プレゼンテーション層
│   │   │   │       ├── NotificationController.kt # 通知コントローラー
│   │   │   │       └── dto/
│   │   │   │           ├── request/
│   │   │   │           │   └── NotificationRequest.kt
│   │   │   │           └── response/
│   │   │   │               └── NotificationResponse.kt
│   │   │   │
│   │   │   ├── infrastructure/                   # 共通インフラストラクチャ
│   │   │   │   ├── storage/                      # ストレージインフラストラクチャ
│   │   │   │   │   ├── S3FileStorage.kt          # S3ファイルストレージ実装
│   │   │   │   │   └── FileStorageService.kt     # ファイルストレージサービスインターフェース
│   │   │   │   │
│   │   │   │   └── email/                        # メール送信インフラストラクチャ
│   │   │   │       └── SpringMailSender.kt       # Spring Mailを使用したメール送信実装
│   │   │   │
│   │   │   └── presentation/                     # 共通プレゼンテーション層
│   │   │       └── websocket/                    # WebSocket設定
│   │   │           └── WebSocketConfig.kt        # WebSocket設定
│   │   │
│   │   └── resources/                            # リソースディレクトリ
│   │       ├── application.yml                   # アプリケーション設定
│   │       ├── application-dev.yml               # 開発環境設定
│   │       └── application-prod.yml              # 本番環境設定
│   │
│   └── test/                                     # テストディレクトリ
│       └── kotlin/com/example/lineclone/
│           ├── domain/                           # ドメイン層テスト
│           │   ├── auth/
│           │   ├── user/
│           │   ├── chat/
│           │   └── notification/
│           │
│           ├── application/                      # アプリケーション層テスト
│           │   ├── auth/
│           │   ├── user/
│           │   ├── chat/
│           │   └── notification/
│           │
│           ├── infrastructure/                   # インフラストラクチャ層テスト
│           │   ├── auth/
│           │   ├── user/
│           │   ├── chat/
│           │   └── notification/
│           │
│           ├── presentation/                     # プレゼンテーション層テスト
│           │   └── controller/
│           │
│           └── integration/                      # 統合テスト
│               ├── auth/
│               ├── user/
│               ├── chat/
│               └── notification/
│
└── web/                                          # Webフロントエンド（Next.js）
    ├── package.json
    ├── next.config.js
    ├── tailwind.config.js
    ├── vitest.config.ts
    ├── tsconfig.json
    ├── .env.local
    ├── public/
    ├── src/
    │   ├── app/                                  # Next.js App Router
    │   │   ├── layout.tsx
    │   │   ├── page.tsx
    │   │   ├── chat/
    │   │   │   ├── [roomId]/
    │   │   │   │   └── page.tsx
    │   │   │   └── page.tsx
    │   │   ├── friends/
    │   │   │   └── page.tsx
    │   │   ├── profile/
    │   │   │   └── page.tsx
    │   │   ├── settings/
    │   │   │   └── page.tsx
    │   │   ├── auth/
    │   │   │   ├── signin/
    │   │   │   │   └── page.tsx
    │   │   │   └── signup/
    │   │   │       └── page.tsx
    │   │   └── api/                              # APIルート
    │   │       └── [...path]/
    │   │           └── route.ts                  # APIプロキシ
    │   │
    │   ├── components/                           # UIコンポーネント
    │   │   ├── auth/
    │   │   ├── chat/
    │   │   ├── user/
    │   │   ├── common/
    │   │   └── layout/
    │   │
    │   ├── hooks/                                # Reactフック
    │   │   ├── useAuth.ts
    │   │   ├── useChat.ts
    │   │   ├── useWebSocket.ts
    │   │   └── useNotification.ts
    │   │
    │   ├── lib/                                  # ユーティリティ
    │   │   ├── api.ts                            # APIクライアント
    │   │   ├── auth.ts                           # 認証ユーティリティ
    │   │   └── validation.ts                     # バリデーションユーティリティ
    │   │
    │   ├── types/                                # TypeScript型定義
    │   │   ├── auth.ts
    │   │   ├── user.ts
    │   │   ├── chat.ts
    │   │   └── notification.ts
    │   │
    │   └── styles/                               # スタイル
    │       └── globals.css
    │
    └── tests/                                    # フロントエンドテスト
        ├── components/
        ├── hooks/
        ├── utils/
        └── e2e/                                  # E2Eテスト（Playwright）
```

## ドメイン境界とパッケージ構造の説明

### ドメイン境界

本プロジェクトでは、以下の主要なドメイン境界を定義しています：

1. **認証ドメイン（auth）**
   - ユーザー認証、ログイン、ログアウト、トークン管理など
   - サインアップ、サインイン、パスワードリセットなどの認証機能

2. **ユーザードメイン（user）**
   - ユーザープロフィール管理
   - 友達関係の管理
   - ユーザー設定

3. **チャットドメイン（chat）**
   - メッセージ送受信
   - チャットルーム管理
   - チャットメンバー管理
   - 既読管理

4. **通知ドメイン（notification）**
   - プッシュ通知
   - 通知設定
   - デバイストークン管理

### クリーンアーキテクチャレイヤー構造

各ドメイン境界内で、以下のクリーンアーキテクチャの層構造を適用しています：

1. **ドメイン層**
   - **エンティティ**: ビジネスルールを持つドメインオブジェクト（例: User, Message, ChatRoom）
   - **値オブジェクト**: 不変で同一性のないオブジェクト（例: Email, MessageContent）
   - **リポジトリインターフェース**: ドメインオブジェクトの永続化インターフェース
   - **ドメインサービス**: エンティティに属さないドメインロジック

2. **アプリケーション層**
   - **ユースケース**: 特定のビジネスケースを実装するサービス（例: SendMessageUseCase）
   - **コマンド/クエリ**: ユースケースへの入力データを表すDTO
   - **結果オブジェクト**: ユースケースの出力データを表すDTO

3. **インフラストラクチャ層**
   - **リポジトリ実装**: jOOQを使用したリポジトリの具体的な実装
   - **外部サービス実装**: S3, Firebase, Mailなどの外部サービスとの連携実装
   - **キャッシュ実装**: Redisを使用したキャッシュの実装

4. **プレゼンテーション層**
   - **コントローラー**: REST APIエンドポイントを提供
   - **リクエスト/レスポンスDTO**: API入出力データの定義
   - **WebSocketハンドラ**: リアルタイム通信の実装

### パッケージ構造と依存関係

プロジェクト構造では、クリーンアーキテクチャのレイヤーをドメイン境界ごとに配置しています：

```
com.example.lineclone
    ├── auth/                    # 認証ドメイン境界
    │   ├── domain/              # ドメイン層
    │   ├── application/         # アプリケーション層
    │   ├── infrastructure/      # インフラストラクチャ層
    │   └── presentation/        # プレゼンテーション層
    ├── user/                    # ユーザードメイン境界
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    ├── chat/                    # チャットドメイン境界
    │   ├── domain/
    │   ├── application/
    │   ├── infrastructure/
    │   └── presentation/
    └── notification/            # 通知ドメイン境界
        ├── domain/
        ├── application/
        ├── infrastructure/
        └── presentation/
```

この構造によって、ドメイン境界が明確に分離され、各ドメイン内でクリーンアーキテクチャの層が適用されています。

### 依存関係の方向

クリーンアーキテクチャの重要な原則として、依存関係は常に内側のレイヤーに向けています：

- プレゼンテーション層 → アプリケーション層 → ドメイン層
- インフラストラクチャ層 → ドメイン層

各ドメイン境界内では：
- ドメイン層は他のどの層にも依存せず
- アプリケーション層はドメイン層にのみ依存
- インフラストラクチャ層はドメイン層に依存
- プレゼンテーション層はアプリケーション層に依存

これにより、ドメインロジックが外部技術の変更から保護され、各ドメイン境界内での責務が明確に分離されています。

## Gradle設定

プロジェクトのGradle設定は以下のようになっています：

```kotlin
// build.gradle.kts
plugins {
    id("org.springframework.boot") version "3.2.0"
    id("io.spring.dependency-management") version "1.1.4"
    kotlin("jvm") version "1.9.21"
    kotlin("plugin.spring") version "1.9.21"
    id("org.jooq.jooq-codegen") version "8.2"
    id("nu.studer.jooq") version "8.2"
}

group = "com.example"
version = "0.0.1-SNAPSHOT"

java {
    sourceCompatibility = JavaVersion.VERSION_21
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Boot
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-data-redis")
    implementation("org.springframework.boot:spring-boot-starter-websocket")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    
    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
    
    // jOOQ
    implementation("org.springframework.boot:spring-boot-starter-jooq")
    jooqGenerator("mysql:mysql-connector-java:8.0.33")
    
    // AWS SDK for S3
    implementation("software.amazon.awssdk:s3:2.21.0")
    
    // JWT
    implementation("io.jsonwebtoken:jjwt-api:0.11.5")
    runtimeOnly("io.jsonwebtoken:jjwt-impl:0.11.5")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.11.5")
    
    // Firebase
    implementation("com.google.firebase:firebase-admin:9.2.0")
    
    // Dotenv
    implementation("io.github.cdimascio:dotenv-kotlin:6.4.1")
    
    // Testing
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("io.kotest:kotest-runner-junit5:5.7.2")
    testImplementation("io.kotest:kotest-assertions-core:5.7.2")
    testImplementation("io.kotest:kotest-property:5.7.2")
    testImplementation("io.mockk:mockk:1.13.8")
    testImplementation("org.springframework.security:spring-security-test")
}

jooq {
    configurations {
        create("main") {
            jooqConfiguration {
                jdbc {
                    driver = "com.mysql.cj.jdbc.Driver"
                    url = "jdbc:mysql://localhost:3306/lineclone"
                    user = System.getenv("DB_USER") ?: "root"
                    password = System.getenv("DB_PASSWORD") ?: "password"
                }
                generator {
                    database {
                        name = "org.jooq.meta.mysql.MySQLDatabase"
                        inputSchema = "lineclone"
                    }
                    generate {
                        pojos = true
                        daos = true
                        fluentSetters = true
                    }
                    target {
                        packageName = "com.example.lineclone.infrastructure.jooq"
                        directory = "build/generated-sources/jooq"
                    }
                }
            }
        }
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs += "-Xjsr305=strict"
        jvmTarget = "21"
    }
}
```

## 環境変数の設定 (.env.local)

ローカル開発用の環境設定は以下のようになっています：

```properties
# .env.local
# データベース設定
DB_HOST=localhost
DB_PORT=3306
DB_NAME=lineclone
DB_USER=root
DB_PASSWORD=password

# Redis設定
REDIS_HOST=localhost
REDIS_PORT=6379

# MinIO（S3互換）設定
S3_ENDPOINT=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET=lineclone

# JWT設定
JWT_SECRET=your_jwt_secret_key_here
JWT_EXPIRATION=86400000

# Firebase設定
FIREBASE_PROJECT_ID=lineclone-dev
FIREBASE_PRIVATE_KEY=your_firebase_private_key_here
FIREBASE_CLIENT_EMAIL=your_firebase_client_email_here

# アプリケーション設定
APP_ENV=development
SERVER_PORT=8080
```

環境変数を読み込むためのSpring Boot設定：

```kotlin
// EnvironmentConfig.kt
@Configuration
class EnvironmentConfig {
    init {
        // .env.localファイルが存在する場合は読み込む