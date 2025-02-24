CREATE TABLE media (
    id VARCHAR(36) PRIMARY KEY,
    tweet_id VARCHAR(36) NOT NULL,
    type ENUM('IMAGE', 'VIDEO', 'GIF') NOT NULL,
    url VARCHAR(255) NOT NULL,
    alt_text TEXT,
    width INT,
    height INT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE,
    INDEX idx_tweet_id (tweet_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 