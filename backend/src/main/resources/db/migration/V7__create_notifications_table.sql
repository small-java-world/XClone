CREATE TABLE notifications (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    type ENUM('LIKE', 'RETWEET', 'FOLLOW', 'MENTION', 'REPLY') NOT NULL,
    actor_id VARCHAR(36) NOT NULL,
    tweet_id VARCHAR(36),
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (tweet_id) REFERENCES tweets(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_actor_id (actor_id),
    INDEX idx_tweet_id (tweet_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; 