CREATE TABLE user_profiles (
    user_id VARCHAR(36) PRIMARY KEY,
    display_name VARCHAR(50),
    bio TEXT,
    location VARCHAR(100),
    website_url VARCHAR(255),
    avatar_url VARCHAR(255),
    header_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 