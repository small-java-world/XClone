package com.example.app.integration

import mu.KotlinLogging
import org.springframework.stereotype.Service

private val logger = KotlinLogging.logger {}

@Service
class TweetNotificationIntegrationService {
    fun processTweetPosted(userId: String, tweetId: String) {
        logger.info {
            """{
                "timestamp": "${System.currentTimeMillis()}",
                "level": "INFO",
                "eventType": "TweetPostedEvent",
                "operation": "TweetNotificationIntegrationService.processTweetPosted",
                "userId": "${userId.take(4)}****",
                "tweetId": "$tweetId",
                "message": "統合サービスでTweetPostedEventを受信"
            }""".trimIndent()
        }
        
        // TODO: 通知の作成処理を実装
        logger.info { "統合サービスでのTweetPostedEvent処理完了" }
    }
} 