```markdown
# XClone

XClone は、X（旧Twitter）の機能をクローンしたアプリケーションです。  
本プロジェクトは、ドメイン駆動設計 (DDD) の原則に基づいて設計・実装され、最新の技術スタックを活用して高い拡張性と保守性を実現しています。

---

## 目次

- [概要](#概要)
- [特徴](#特徴)
- [技術スタック](#技術スタック)
- [アーキテクチャ](#アーキテクチャ)
- [セットアップ](#セットアップ)
  - [ローカル環境の構築](#ローカル環境の構築)
  - [Flyway マイグレーション](#flyway-マイグレーション)
- [実行方法](#実行方法)
- [テスト](#テスト)
  - [バックエンドテスト (UT)](#バックエンドテスト-ut)
  - [フロントエンドテスト (UT)](#フロントエンドテスト-ut)
  - [E2E テスト](#e2e-テスト)
- [ディレクトリ構成](#ディレクトリ構成)
- [ライセンス](#ライセンス)

---

## 概要

XClone は、Twitter のコア機能（ユーザ登録、ツイート投稿、通知管理など）を実装したクローンアプリケーションです。  
バックエンドは Kotlin 2.x と Spring Boot を用い、型安全なデータアクセスには jOOQ、ログ出力は kotlin‑logging を利用しています。  
DB マイグレーションは Flyway により管理し、MySQL および S3 互換の MinIO を Docker Compose 環境下で運用します。  
フロントエンドは Next.js（React と TypeScript）を利用し、UI は Tailwind CSS と shadcn/ui で構築、テストは Vitest および Playwright を採用しています。

---

## 特徴

- **ドメイン駆動設計 (DDD)** に基づいた層別アーキテクチャ  
  - ドメイン、ユースケース、リポジトリ（インターフェース）とその実装（インフラストラクチャ層）、統合用ドメインサービスで分離
- **イベント駆動設計**  
  - ツイート投稿などのイベントに対して、独立した統合用ドメインサービスが通知生成を実現
- **堅牢なデータ管理**  
  - Flyway を用いた冪等性のある DB マイグレーション
  - Docker Compose による MySQL および MinIO の環境管理
- **充実したテスト戦略**  
  - バックエンドは Kotest と Mockk、フロントエンドは Vitest、E2E テストは Playwright により品質を担保

---

## 技術スタック

### バックエンド
- **言語**: Kotlin 2.x
- **フレームワーク**: Spring Boot ^3.1.3
- **ORM**: jOOQ ^3.18.2
- **ログ出力**: kotlin‑logging ^3.0.5
- **DBマイグレーション**: Flyway
- **テスト**: Kotest ^5.6.2、Mockk ^1.13.5
- **データベース**: MySQL 8.0.33
- **オブジェクトストレージ**: MinIO (S3 互換)

### フロントエンド
- **フレームワーク**: Next.js ^15.1.3, React ^19.0.0
- **言語**: TypeScript ^5.0.0
- **UI**: Tailwind CSS ^3.4.17, shadcn/ui ^2.1.8
- **テスト**: Vitest, Playwright (E2E)

### 開発ツール
- **npm**: ^10.0.0
- **ESLint**: ^9.0.0

---

## アーキテクチャ

本アプリは以下の主要な層に分かれています：

1. **Adapter 層**  
   - REST API コントローラやイベントリスナーを配置
2. **Domain 層**  
   - エンティティ、値オブジェクト、ドメインイベント、ファクトリー、及びリポジトリのインターフェースを配置
3. **Usecase 層**  
   - 各種コマンド（RegisterUserCommand、PostTweetCommand、CreateNotificationCommand など）を受け取り、ドメイン層の処理を実行する
4. **Repository／Infrastructure 層**  
   - 永続化の実装は各バウンデッドコンテキストのインフラストラクチャ層（`infrastructure/repository`）に配置
5. **Integration 層**  
   - 統合用ドメインサービス（TweetNotificationIntegrationService）を介して、複数のバウンデッドコンテキスト間の連携を実現

---

## セットアップ

### ローカル環境の構築

1. **Docker Compose の実行**  
   プロジェクトルートで以下のコマンドを実行し、MySQL と MinIO のコンテナを起動します。

   ```bash
   docker-compose up -d
   ```

2. **Spring Boot アプリケーションの起動**  
   IDEまたはコマンドラインから Spring Boot アプリケーションを起動します。

### Flyway マイグレーション

- マイグレーションファイルは `src/main/resources/db/migration` に配置されます。  
- アプリケーション起動時に Flyway が自動的にマイグレーションファイルを検出・実行します。

---

## 実行方法

### バックエンド
- Spring Boot アプリケーションを起動します。
- API エンドポイントは、`http://localhost:8080`（例）でアクセス可能です。

### フロントエンド
- フロントエンドプロジェクトディレクトリで以下のコマンドを実行して開発サーバーを起動します。

  ```bash
  npm install
  npm run dev
  ```

- アプリケーションは `http://localhost:3000` で動作します。

---

## テスト

### バックエンドテスト (UT)
- **ツール**: Kotest, Mockk  
- テスト用DBを利用し、実際のSQLを発行して検証します。
- 共通テストデータは、`src/test/resources/common_test_data.sql` などから投入します。
- テスト前に、JDBC経由で参照整合性を無効化、テスト後に再有効化する自動化スクリプトを利用しています。

### フロントエンドテスト (UT)
- **ツール**: Vitest  
- 各画面（HomeScreen, UserScreen, TweetScreen, NotificationScreen）ごとに、Container コンポーネントと Presentational コンポーネントのテストを実施します。

### E2E テスト
- **ツール**: Playwright  
- バックエンドとフロントエンドの連携シナリオ（ユーザ登録、ツイート投稿、通知取得、通知タップによる既読処理）を検証する独立したテストプロジェクト（`e2e/`）として管理しています。

---

## ディレクトリ構成

```
project-root/
├── backend/
│   ├── build.gradle.kts
│   ├── Dockerfile
│   └── src/
│       ├── main/
│       │   ├── kotlin/
│       │   │   └── com/example/app/
│       │   │       ├── Application.kt
│       │   │       ├── config/
│       │   │       ├── integration/
│       │   │       │   └── TweetNotificationIntegrationService.kt
│       │   │       ├── user/
│       │   │       │   ├── adapter/
│       │   │       │   │   ├── controller/
│       │   │       │   │   │   └── UserController.kt
│       │   │       │   │   └── event/
│       │   │       │   │       └── UserEventListener.kt
│       │   │       │   ├── domain/
│       │   │       │   │   ├── event/
│       │   │       │   │   │   ├── UserRegisteredEvent.kt
│       │   │       │   │   │   └── UserProfileUpdatedEvent.kt
│       │   │       │   │   ├── model/
│       │   │       │   │   │   ├── User.kt
│       │   │       │   │   │   ├── Follow.kt
│       │   │       │   │   │   └── UserProfile.kt
│       │   │       │   │   └── valueobject/
│       │   │       │   │       ├── EmailAddress.kt
│       │   │       │   │       ├── UserName.kt
│       │   │       │   │       └── Password.kt
│       │   │       │   ├── factory/
│       │   │       │   │   └── UserFactory.kt
│       │   │       │   ├── usecase/
│       │   │       │   │   ├── RegisterUserCommand.kt
│       │   │       │   │   ├── UpdateUserProfileCommand.kt
│       │   │       │   │   └── UserUsecase.kt
│       │   │       │   └── repository/         // インターフェース
│       │   │       │       └── UserRepository.kt
│       │   │       ├── user/infrastructure/    // 実装
│       │   │       │   └── repository/
│       │   │       │       └── UserRepositoryImpl.kt
│       │   │       ├── tweet/
│       │   │       │   ├── adapter/
│       │   │       │   │   ├── controller/
│       │   │       │   │   │   └── TweetController.kt
│       │   │       │   │   └── event/
│       │   │       │   │       └── TweetEventListener.kt
│       │   │       │   ├── domain/
│       │   │       │   │   ├── event/
│       │   │       │   │   │   ├── TweetPostedEvent.kt
│       │   │       │   │   │   ├── TweetEditedEvent.kt
│       │   │       │   │   │   └── TweetDeletedEvent.kt
│       │   │       │   │   ├── model/
│       │   │       │   │   │   ├── Tweet.kt
│       │   │       │   │   │   ├── Like.kt
│       │   │       │   │   │   ├── Retweet.kt
│       │   │       │   │   │   └── Media.kt
│       │   │       │   │   └── valueobject/
│       │   │       │   │       ├── TweetText.kt
│       │   │       │   │       ├── MediaUrl.kt
│       │   │       │   │       └── MediaType.kt
│       │   │       │   ├── factory/
│       │   │       │   │   └── TweetFactory.kt
│       │   │       │   ├── usecase/
│       │   │       │   │   ├── PostTweetCommand.kt
│       │   │       │   │   ├── EditTweetCommand.kt
│       │   │       │   │   └── TweetUsecase.kt
│       │   │       │   └── repository/         // インターフェース
│       │   │       │       └── TweetRepository.kt
│       │   │       ├── tweet/infrastructure/   // 実装
│       │   │       │   └── repository/
│       │   │       │       └── TweetRepositoryImpl.kt
│       │   │       ├── notification/
│       │   │       │   ├── adapter/
│       │   │       │   │   ├── controller/
│       │   │       │   │   │   └── NotificationController.kt
│       │   │       │   │   └── event/
│       │   │       │   │       └── NotificationEventListener.kt
│       │   │       │   ├── domain/
│       │   │       │   │   ├── event/
│       │   │       │   │   │   └── NotificationCreatedEvent.kt
│       │   │       │   │   ├── model/
│       │   │       │   │   │   └── Notification.kt
│       │   │       │   │   └── valueobject/
│       │   │       │   │       ├── NotificationType.kt
│       │   │       │   │       └── NotificationContent.kt
│       │   │       │   ├── factory/
│       │   │       │   │   └── NotificationFactory.kt
│       │   │       │   ├── usecase/
│       │   │       │   │   ├── CreateNotificationCommand.kt
│       │   │       │   │   └── NotificationUsecase.kt
│       │   │       │   └── repository/         // インターフェース
│       │   │       │       └── NotificationRepository.kt
│       │   │       ├── notification/infrastructure/  // 実装
│       │   │       │   └── repository/
│       │   │       │       └── NotificationRepositoryImpl.kt
│       │   └── resources/
│       │       └── application.yml
│       └── test/
│           └── kotlin/
│               └── com/example/app/
│                   ├── user/
│                   │   ├── adapter/controller/
│                   │   │   └── UserControllerTest.kt
│                   │   ├── domain/model/
│                   │   │   └── UserTest.kt
│                   │   ├── domain/event/
│                   │   │   └── UserEventTest.kt
│                   │   ├── domain/valueobject/
│                   │   │   ├── EmailAddressTest.kt
│                   │   │   ├── UserNameTest.kt
│                   │   │   └── PasswordTest.kt
│                   │   ├── usecase/
│                   │   │   └── UserUsecaseTest.kt
│                   │   └── repository/
│                   │       └── infrastructure/repository/
│                   │           └── UserRepositoryImplTest.kt
│                   ├── tweet/
│                   │   ├── adapter/controller/
│                   │   │   └── TweetControllerTest.kt
│                   │   ├── domain/model/
│                   │   │   └── TweetTest.kt
│                   │   ├── domain/event/
│                   │   │   └── TweetEventTest.kt
│                   │   ├── domain/valueobject/
│                   │   │   ├── TweetTextTest.kt
│                   │   │   ├── MediaUrlTest.kt
│                   │   │   └── MediaTypeTest.kt
│                   │   ├── usecase/
│                   │   │   └── TweetUsecaseTest.kt
│                   │   └── repository/
│                   │       └── infrastructure/repository/
│                   │           └── TweetRepositoryImplTest.kt
│                   └── notification/
│                       ├── adapter/controller/
│                       │   └── NotificationControllerTest.kt
│                       ├── domain/model/
│                       │   └── NotificationTest.kt
│                       ├── domain/event/
│                       │   └── NotificationEventTest.kt
│                       ├── domain/valueobject/
│                       │   ├── NotificationTypeTest.kt
│                       │   └── NotificationContentTest.kt
│                       ├── usecase/
│                       │   └── NotificationUsecaseTest.kt
│                       └── repository/
│                           └── infrastructure/repository/
│                               └── NotificationRepositoryImplTest.kt
├── frontend/
│   ├── package.json
│   ├── next.config.js
│   ├── pages/
│   │   ├── index.tsx
│   │   ├── user.tsx
│   │   ├── tweet.tsx
│   │   └── notification.tsx
│   ├── components/
│   │   ├── HomeScreen/
│   │   │   ├── containers/
│   │   │   │   └── HomeContainer.tsx
│   │   │   └── presentational/
│   │   │       ├── Header.tsx
│   │   │       ├── Footer.tsx
│   │   │       └── MainContent.tsx
│   │   ├── UserScreen/
│   │   │   ├── containers/
│   │   │   │   └── UserContainer.tsx
│   │   │   └── presentational/
│   │   │       ├── UserProfile.tsx
│   │   │       └── UserPosts.tsx
│   │   ├── TweetScreen/
│   │   │   ├── containers/
│   │   │   │   └── TweetContainer.tsx
│   │   │   └── presentational/
│   │   │       ├── TweetItem.tsx
│   │   │       └── TweetDetail.tsx
│   │   └── NotificationScreen/
│   │       ├── containers/
│   │       │   └── NotificationContainer.tsx
│   │       └── presentational/
│   │           ├── NotificationItem.tsx
│   │           └── NotificationList.tsx
│   ├── hooks/
│   │   └── useNotificationPolling.ts
│   ├── utils/
│   │   └── apiClient.ts
│   └── tests/
│       ├── HomeScreen/
│       │   ├── containers/
│       │   │   └── HomeContainer.test.tsx
│       │   └── presentational/
│       │       ├── Header.test.tsx
│       │       ├── Footer.test.tsx
│       │       └── MainContent.test.tsx
│       ├── UserScreen/
│       │   ├── containers/
│       │   │   └── UserContainer.test.tsx
│       │   └── presentational/
│       │       ├── UserProfile.test.tsx
│       │       └── UserPosts.test.tsx
│       ├── TweetScreen/
│       │   ├── containers/
│       │   │   └── TweetContainer.test.tsx
│       │   └── presentational/
│       │       ├── TweetItem.test.tsx
│       │       └── TweetDetail.test.tsx
│       └── NotificationScreen/
│           ├── containers/
│           │   └── NotificationContainer.test.tsx
│           └── presentational/
│               ├── NotificationItem.test.tsx
│               └── NotificationList.test.tsx
├── e2e/
│   ├── package.json
│   ├── playwright.config.ts
│   └── tests/
│       └── e2e.test.ts       // バックエンドとフロントエンドの連携シナリオを記述
└── README.md
```

---

## 11. 結果報告例

```markdown
# 実行結果報告

## 概要
XClone のリポジトリに関するプロジェクトルールを更新しました。  
リポジトリインターフェースは各ドメイン層に配置し、実装はインフラストラクチャ層（infrastructure/repository）に配置するルールを適用。  
また、UTでは専用テスト用DBを利用し、共通テストデータは個別にSQLを発行する方式を採用する設定も導入しました。

## 実行ステップ
1. リポジトリの配置ルールを見直し、インターフェースは `com.example.app.{context}.repository` に、実装は `com.example.app.{context}.infrastructure/repository` に配置するよう更新。
2. ワイルドカードルールとして `**/infrastructure/repository/**/*.kt` を適用し、全ての実装ファイルに一括ルールを適用する設定を追加。
3. バックエンドUTにおいて、テスト用DB利用と共通テストデータ投入のガイドライン（参照整合性の無効化・削除・SQL投入・再有効化）をルールに盛り込む。
4. ルールが正しく適用されることを検証し、結果を確認。

## 最終成果物
- 更新済みの .cursorrules（本ドキュメント）
- リポジトリ配置およびテスト用ルールが適用されたソースコードとテストコード

## 課題対応
- リポジトリ実装を正しいインフラストラクチャ層に移動することで、ドメイン層の独立性を確保
- UTにおけるテストデータ投入方法を明確化し、冪等性のあるテスト環境を実現

## 注意点・改善提案
- テストデータ投入処理の自動化スクリプトの整備を引き続き進める
- 将来的にリポジトリ実装の拡張があった場合、ルールの見直しを適宜実施する
```

---

## 12. 重要な注意事項

- 不明点は作業開始前に必ず確認してください。
- 重要な判断が必要な場合は、その都度報告し、承認を得ること。
- 予期せぬ問題が発生した場合は、即時報告し、対応策を提案してください。
- **明示的に指示されていない変更は行わないこと。** 必要な変更があれば、まず提案して承認を得ること。
- **UI/UX の変更（レイアウト、色、フォント、間隔など）は禁止です。** 変更が必要な場合は、事前に理由を示し、承認を得てください。
- **技術スタックに記載されたバージョンは変更しないこと。**

---

## 13. 補足: 技術スタック詳細（変更禁止の項目）

- **コア技術（変更禁止）**:
  - **TypeScript**: ^5.0.0  
  - **Node.js**: ^20.0.0  
  - **Java**: 21  
  - **Kotlin**: 2.x  
  - **AIモデル**: Claude-3-Sonnet-20241022 (Anthropic Messages API 2023-06-01)
- **フロントエンド**:
  - **Next.js**: ^15.1.3  
  - **React**: ^19.0.0  
  - **Tailwind CSS**: ^3.4.17  
  - **shadcn/ui**: ^2.1.8
- **バックエンド**:
  - **MySQL**: 8.0.33  
  - **jOOQ**: ^3.18.2  
  - **Spring Boot**: ^3.1.3  
  - **kotlin‑logging**: ^3.0.5  
  - **Kotest**: ^5.6.2  
  - **Mockk**: ^1.13.5
- **開発ツール**:
  - **npm**: ^10.0.0  
  - **ESLint**: ^9.0.0  
  - **TypeScript**: ^5.0.0
- **API バージョン管理**:
  - API クライアントは `app/lib/api/client.ts`、型定義は `types.ts`、環境設定は `config.ts` で一元管理。これらのファイルは変更禁止です。

---

以上が、リポジトリに関するプロジェクトルールとテストデータ投入方法を含む更新済みの .cursorrules です。  
このルールに基づき、リポジトリ実装およびテストの実装タスクを遂行してください。
```