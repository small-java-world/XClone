package com.example.app.user.domain.model

import com.example.app.user.domain.valueobject.EmailAddress
import com.example.app.user.domain.valueobject.Password
import com.example.app.user.domain.valueobject.UserName
import java.util.UUID

data class User(
    val id: String = UUID.randomUUID().toString(),
    val email: EmailAddress,
    val username: UserName,
    val password: Password,
    val profile: UserProfile? = null
) {
    companion object {
        fun create(
            email: String,
            username: String,
            password: String
        ): User {
            return User(
                email = EmailAddress(email),
                username = UserName(username),
                password = Password(password)
            )
        }
    }
} 