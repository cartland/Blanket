package com.chriscartland.blanket

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform
