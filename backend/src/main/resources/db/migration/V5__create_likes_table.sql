CREATE TABLE likes (
    user_id VARCHAR(36) NOT NULL,
    tweet_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, tweet_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE,
    INDEX idx_tweet_id (tweet_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 