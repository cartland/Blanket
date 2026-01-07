package com.chriscartland.blanket

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertContains
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class SharedCommonTest {

    @Test
    fun greetingReturnsNonNullString() {
        val greeting = Greeting()
        val result = greeting.greet()
        assertNotNull(result, "Greeting should not return null")
    }

    @Test
    fun greetingReturnsNonEmptyString() {
        val greeting = Greeting()
        val result = greeting.greet()
        assertTrue(result.isNotEmpty(), "Greeting should not be empty")
    }

    @Test
    fun greetingContainsHello() {
        val greeting = Greeting()
        val result = greeting.greet()
        assertContains(result, "Hello", message = "Greeting should contain 'Hello'")
    }

    @Test
    fun greetingContainsPlatformName() {
        val greeting = Greeting()
        val result = greeting.greet()
        val platform = getPlatform()
        assertContains(result, platform.name, message = "Greeting should contain platform name")
    }

    @Test
    fun greetingHasCorrectFormat() {
        val greeting = Greeting()
        val result = greeting.greet()
        val platform = getPlatform()
        val expected = "Hello, ${platform.name}!"
        assertEquals(expected, result, "Greeting should match expected format")
    }
}
