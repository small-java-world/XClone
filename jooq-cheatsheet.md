# jOOQ チートシート (改訂版)

## 1. jOOQとは

jOOQは「Java Object Oriented Querying」の略で、型安全なSQLを構築できるJavaライブラリです。データベースのメタデータからJavaコードを生成し、SQLを文字列ではなくJavaオブジェクトとして扱うことができます。

### 基本コンセプト

- **型安全SQL構築**: 文字列ではなく生成されたメタデータクラスを使用
- **ジェネレータで自動生成されるクラス**:
  - テーブル定数: `com.example.jooq.Tables`
  - テーブルクラス: `com.example.jooq.tables.Users`
  - レコードクラス: `com.example.jooq.tables.records.UsersRecord`
  - POJOクラス: `com.example.jooq.tables.pojos.User`
  - DAOクラス: `com.example.jooq.tables.daos.UserDao`

## 2. セットアップ

### Gradleセットアップと生成物のインポート（複数DB対応）

```kotlin
// build.gradle.kts
plugins {
    kotlin("jvm") version "1.9.0"
    id("org.jooq.jooq-codegen-gradle") version "3.18.x"
}

// 依存関係
dependencies {
    // jOOQ関連
    implementation("org.jooq:jooq:3.18.6")
    implementation("org.jooq:jooq-meta:3.18.6")
    implementation("org.jooq:jooq-codegen:3.18.6")
    
    // データベースドライバー
    implementation("org.postgresql:postgresql:42.6.0")
    implementation("mysql:mysql-connector-java:8.0.33")
    
    // Spring関連（オプション）
    implementation("org.springframework.boot:spring-boot-starter-jooq:3.2.0")
    implementation("org.springframework.boot:spring-boot-starter-jdbc:3.2.0")
}

// jOOQの設定（複数DB対応）
jooq {
    version.set("3.18.x")
    configurations {
        // メインDB (PostgreSQL)
        create("mainDb") {
            generateSchemaSourceOnCompilation.set(true)
            jdbc {
                driver = "org.postgresql.Driver"
                url = "jdbc:postgresql://localhost:5432/maindb"
                user = "postgres"
                password = "postgres"
            }
            generator {
                database {
                    name = "org.jooq.meta.postgres.PostgresDatabase"
                    includes = ".*"
                    excludes = "flyway_schema_history | jooq_.*"
                    // スキーマを指定
                    inputSchema = "public"
                }
                target {
                    // メインDBのパッケージ名
                    packageName = "com.example.jooq.maindb"
                    directory = "${project.buildDir}/generated-src/jooq/mainDb"
                }
            }
        }
        
        // サブDB (MySQL)
        create("legacyDb") {
            generateSchemaSourceOnCompilation.set(true)
            jdbc {
                driver = "com.mysql.cj.jdbc.Driver"
                url = "jdbc:mysql://localhost:3306/legacydb"
                user = "root"
                password = "root"
            }
            generator {
                database {
                    name = "org.jooq.meta.mysql.MySQLDatabase"
                    includes = ".*"
                    excludes = "flyway_schema_history | jooq_.*"
                }
                target {
                    // レガシーDBのパッケージ名
                    packageName = "com.example.jooq.legacydb"
                    directory = "${project.buildDir}/generated-src/jooq/legacyDb"
                }
            }
        }
    }
}
```

### ベーシックな接続設定

```kotlin
// 必要なインポート
import org.jooq.DSLContext
import org.jooq.SQLDialect
import org.jooq.impl.DSL
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import javax.sql.DataSource

// 基本的なDSLContextの作成
val mainDbCreate = DSL.using(mainDbConnection, SQLDialect.POSTGRES)
val legacyDbCreate = DSL.using(legacyDbConnection, SQLDialect.MYSQL)

// Spring Bootでの設定例
@Configuration
class JooqConfiguration(
    @Qualifier("mainDataSource") private val mainDataSource: DataSource,
    @Qualifier("legacyDataSource") private val legacyDataSource: DataSource
) {
    @Bean
    @Qualifier("mainDSLContext")
    fun mainDSLContext(): DSLContext {
        return DSL.using(
            mainDataSource,
            SQLDialect.POSTGRES
        )
    }
    
    @Bean
    @Qualifier("legacyDSLContext")
    fun legacyDSLContext(): DSLContext {
        return DSL.using(
            legacyDataSource,
            SQLDialect.MYSQL
        )
    }
}
```

### 生成コードのインポート

```kotlin
// DBごとに異なるパッケージからのインポート

// メインDB (PostgreSQL)のテーブル
import com.example.jooq.maindb.Tables.USERS
import com.example.jooq.maindb.tables.Users
import com.example.jooq.maindb.tables.records.UsersRecord

// レガシーDB (MySQL)のテーブル
import com.example.jooq.legacydb.Tables.LEGACY_ORDERS
import com.example.jooq.legacydb.tables.LegacyOrders
import com.example.jooq.legacydb.tables.records.LegacyOrdersRecord
```

## 3. 基本クエリ操作

### SELECT クエリ

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import org.jooq.Result
import org.jooq.Record
import org.jooq.Record2

// 基本SELECT
val result: Result<Record> = dsl.select().from(USERS).fetch()

// 特定カラム
val result: Result<Record2<Int?, String?>> = dsl
    .select(USERS.ID, USERS.NAME)
    .from(USERS)
    .fetch()

// WHERE条件
val result = dsl
    .selectFrom(USERS)
    .where(USERS.EMAIL.like("%.com"))
    .and(USERS.ACTIVE.eq(true))
    .fetch()
```

### INSERT クエリ

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import com.example.jooq.maindb.tables.records.UsersRecord

// 基本INSERT（レコードAPIを使用）
val user: UsersRecord = dsl.newRecord(USERS)
user.name = "John"
user.email = "john@example.com"
user.store()

// DSLを使用したINSERT
val inserted = dsl
    .insertInto(USERS, USERS.NAME, USERS.EMAIL)
    .values("John", "john@example.com")
    .execute()

// INSERT後にレコード取得（自動生成ID使用）
val insertedUser = dsl
    .insertInto(USERS, USERS.NAME, USERS.EMAIL)
    .values("John", "john@example.com")
    .returning() // 全カラム返却
    .fetchOne()

// 特定カラムのみ返却
val insertedId = dsl
    .insertInto(USERS, USERS.NAME, USERS.EMAIL)
    .values("John", "john@example.com")
    .returning(USERS.ID)
    .fetchOne()
```

### UPDATE クエリ

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS

val updated = dsl
    .update(USERS)
    .set(USERS.NAME, "John Doe")
    .where(USERS.ID.eq(1))
    .execute()
```

### DELETE クエリ

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS

val deleted = dsl
    .deleteFrom(USERS)
    .where(USERS.ID.eq(1))
    .execute()
```

## 4. テーブル/カラム参照（型安全なアプローチ）

```kotlin
// 悪い例（文字列）- 型安全でない
mainDbCreate.select().from("USERS").where("ID = ?", 1)

// 良い例（型安全）- メインDB
import com.example.jooq.maindb.Tables.USERS
mainDbCreate.select().from(USERS).where(USERS.ID.eq(1))

// 良い例（型安全）- レガシーDB
import com.example.jooq.legacydb.Tables.LEGACY_ORDERS
legacyDbCreate.select().from(LEGACY_ORDERS).where(LEGACY_ORDERS.ORDER_ID.eq(1))
```

## 5. 結合操作（JOIN）

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import com.example.jooq.maindb.Tables.ORDERS
import org.jooq.Result
import org.jooq.Record

// INNER JOIN
val result: Result<Record> = dsl
    .select(USERS.NAME, ORDERS.ORDER_DATE)
    .from(USERS)
    .join(ORDERS).on(USERS.ID.eq(ORDERS.USER_ID))
    .fetch()

// LEFT OUTER JOIN
val result: Result<Record> = dsl
    .select(USERS.NAME, ORDERS.ORDER_DATE)
    .from(USERS)
    .leftJoin(ORDERS).on(USERS.ID.eq(ORDERS.USER_ID))
    .fetch()
```

## 6. カラム名のエイリアス

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import org.jooq.Field
import org.jooq.Result
import org.jooq.Record1

// AS句でエイリアス
val username: Field<String?> = USERS.NAME.`as`("username")
val result: Result<Record1<String?>> = dsl
    .select(username)
    .from(USERS)
    .fetch()

// テーブルエイリアス（サブクエリやセルフジョインで有用）
val u1 = USERS.`as`("u1")
val u2 = USERS.`as`("u2")

val result = dsl
    .select(u1.NAME, u2.NAME)
    .from(u1)
    .join(u2).on(u1.MANAGER_ID.eq(u2.ID))
    .fetch()
```

## 7. 高度なクエリ操作

### グループ化と集計

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import org.jooq.impl.DSL.count
import org.jooq.Result
import org.jooq.Record2

val result: Result<Record2<String?, Int?>> = dsl
    .select(USERS.DEPARTMENT, count())
    .from(USERS)
    .groupBy(USERS.DEPARTMENT)
    .fetch()
```

### サブクエリ

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import com.example.jooq.maindb.Tables.ORDERS
import org.jooq.SelectConditionStep
import org.jooq.Record1
import java.time.LocalDate

// サブクエリ
val subquery: SelectConditionStep<Record1<Int?>> = dsl
    .select(ORDERS.USER_ID)
    .from(ORDERS)
    .where(ORDERS.ORDER_DATE.gt(LocalDate.now().minusDays(30)))

val result = dsl
    .selectFrom(USERS)
    .where(USERS.ID.`in`(subquery))
    .fetch()
```

### ページネーション

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS

val result = dsl
    .selectFrom(USERS)
    .orderBy(USERS.NAME)
    .limit(10)
    .offset(20)
    .fetch()
```

## 8. エラー処理とNullハンドリング

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import org.jooq.exception.DataAccessException
import org.jooq.exception.DataIntegrityViolationException

// nullableな結果のハンドリング
fun findUserById(id: Int): User {
    return dsl.selectFrom(USERS)
        .where(USERS.ID.eq(id))
        .fetchOneInto(User::class.java)
        ?: throw NotFoundException("User not found with ID: $id")
}

// 結果が存在するかどうかの確認
fun userExists(email: String): Boolean {
    return dsl.fetchExists(
        dsl.selectFrom(USERS)
           .where(USERS.EMAIL.eq(email))
    )
}

// オプショナルな結果の処理
fun findOptionalUserByEmail(email: String): User? {
    return dsl.selectFrom(USERS)
        .where(USERS.EMAIL.eq(email))
        .fetchOneInto(User::class.java)
}

// 例外処理の例
fun updateUserWithValidation(user: User) {
    try {
        val updateCount = dsl.update(USERS)
            .set(USERS.NAME, user.name)
            .set(USERS.EMAIL, user.email)
            .where(USERS.ID.eq(user.id))
            .execute()
            
        if (updateCount == 0) {
            throw NotFoundException("User not found with ID: ${user.id}")
        }
    } catch (e: DataAccessException) {
        // jOOQのデータアクセス例外を処理
        when (e) {
            is DataIntegrityViolationException -> 
                throw BusinessException("メールアドレスが既に使用されています", e)
            else -> throw RepositoryException("データベース操作中にエラーが発生しました", e)
        }
    }
}
```

## 9. トランザクション管理

```kotlin
// 必要なインポート
import com.example.jooq.maindb.Tables.USERS
import com.example.jooq.maindb.Tables.USER_SETTINGS
import org.jooq.DSLContext
import org.jooq.impl.DSL
import org.springframework.transaction.annotation.Transactional

// jOOQのネイティブAPIを使用
fun createUser(user: User, dsl: DSLContext) {
    dsl.transaction { config ->
        val ctx = DSL.using(config)
        
        // ユーザーの登録
        val userId = ctx.insertInto(USERS)
            .set(USERS.NAME, user.name)
            .set(USERS.EMAIL, user.email)
            .returning(USERS.ID)
            .fetchOne()?.getValue(USERS.ID)
            ?: throw RuntimeException("ユーザー登録に失敗しました")
            
        // ユーザー設定の登録
        ctx.insertInto(USER_SETTINGS)
            .set(USER_SETTINGS.USER_ID, userId)
            .set(USER_SETTINGS.THEME, "default")
            .set(USER_SETTINGS.NOTIFICATIONS_ENABLED, true)
            .execute()
    }
}

// Spring @Transactionalを使用
@Service
class UserService(private val dsl: DSLContext) {
    
    @Transactional
    fun createUser(user: User) {
        // ユーザーの登録
        val userId = dsl.insertInto(USERS)
            .set(USERS.NAME, user.name)
            .set(USERS.EMAIL, user.email)
            .returning(USERS.ID)
            .fetchOne()?.getValue(USERS.ID)
            ?: throw RuntimeException("ユーザー登録に失敗しました")
            
        // ユーザー設定の登録
        dsl.insertInto(USER_SETTINGS)
            .set(USER_SETTINGS.USER_ID, userId)
            .set(USER_SETTINGS.THEME, "default")
            .set(USER_SETTINGS.NOTIFICATIONS_ENABLED, true)
            .execute()
    }
}
```

## 10. DDDにおけるリポジトリパターン

### パッケージ構成例

```
com.example.domain.model       // ドメインモデル
  └── user
      ├── User.java           // エンティティ
      ├── UserId.java         // 値オブジェクト
      └── UserRepository.java // リポジトリインターフェース（ドメイン層）

com.example.infrastructure.persistence  // インフラ層
  └── jooq
      └── repository
          └── UserRepositoryImpl.java  // jOOQを使用したリポジトリ実装
```

### リポジトリ実装

```java
// ドメイン層のリポジトリインターフェース
package com.example.domain.model.user;

public interface UserRepository {
    User findById(UserId id);
    void save(User user);
    // ドメインの言葉で表現されたメソッド
}

// インフラ層のリポジトリ実装
package com.example.infrastructure.persistence.jooq.repository;

import static com.example.jooq.Tables.USERS;  // Gradleで生成されたjOOQコード

public class UserRepositoryImpl implements UserRepository {
    private final DSLContext create;
    
    public UserRepositoryImpl(DSLContext create) {
        this.create = create;
    }
    
    @Override
    public User findById(UserId id) {
        // jOOQの生成コードを使った実装
        return create.selectFrom(USERS)
                .where(USERS.ID.eq(id.value()))
                .fetchOneInto(User.class);
    }
    
    @Override
    public void save(User user) {
        // Record APIを使用
        UsersRecord record = create.newRecord(USERS);
        record.setId(user.getId().value());
        record.setName(user.getName());
        record.setEmail(user.getEmail());
        record.store();
    }
}
```
