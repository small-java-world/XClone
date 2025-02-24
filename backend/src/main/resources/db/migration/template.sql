-- {ファイル名}
-- このファイルの目的
-- 依存関係: 依存するテーブルや制約
-- 実行順序: マイグレーションの順序

CREATE TABLE IF NOT EXISTS table_name (
    id VARCHAR(36) PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 