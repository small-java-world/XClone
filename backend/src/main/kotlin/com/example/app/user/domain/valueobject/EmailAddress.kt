package com.example.app.user.domain.valueobject

data class EmailAddress private constructor(
    private val value: String
) {
    init {
        require(value.matches(EMAIL_REGEX)) { "Invalid email format" }
    }

    companion object {
        private val EMAIL_REGEX = Regex(
            "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"
        )

        operator fun invoke(email: String): EmailAddress {
            return EmailAddress(email)
        }
    }

    override fun toString(): String {
        return "${value.take(3)}***@${value.substringAfter('@')}"
    }

    fun toRawString(): String = value
} 