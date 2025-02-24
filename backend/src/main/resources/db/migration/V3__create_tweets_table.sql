CREATE TABLE tweets (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    content TEXT NOT NULL,
    reply_to_id VARCHAR(36),
    retweet_of_id VARCHAR(36),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_id) REFERENCES tweets(id) ON DELETE SET NULL,
    FOREIGN KEY (retweet_of_id) REFERENCES tweets(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_reply_to_id (reply_to_id),
    INDEX idx_retweet_of_id (retweet_of_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 