import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    id("org.springframework.boot") version "3.1.3"
    id("io.spring.dependency-management") version "1.1.3"
    id("org.flywaydb.flyway") version "9.22.3"
    kotlin("jvm") version "1.8.22"
    kotlin("plugin.spring") version "1.8.22"
    kotlin("plugin.jpa") version "1.8.22"
}

group = "com.example"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_17

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.flywaydb:flyway-core")
    implementation("org.flywaydb:flyway-mysql")
    implementation("org.jooq:jooq:3.18.2")
    implementation("org.jetbrains.kotlin:kotlin-reflect")
    implementation("io.github.microutils:kotlin-logging:3.0.5")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    implementation("io.minio:minio:8.5.2")
    
    runtimeOnly("com.mysql:mysql-connector-j")
    
    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("io.kotest:kotest-runner-junit5:5.6.2")
    testImplementation("io.kotest:kotest-assertions-core:5.6.2")
    testImplementation("io.mockk:mockk:1.13.5")
}

tasks.withType<KotlinCompile> {
    kotlinOptions {
        freeCompilerArgs += "-Xjsr305=strict"
        jvmTarget = "17"
    }
}

tasks.withType<Test> {
    useJUnitPlatform()
}

flyway {
    url = "jdbc:mysql://localhost:3306/twitter_clone"
    user = "user"
    password = "userpassword"
    locations = arrayOf("filesystem:src/main/resources/db/migration")
    encoding = "UTF-8"
    outOfOrder = true
} 