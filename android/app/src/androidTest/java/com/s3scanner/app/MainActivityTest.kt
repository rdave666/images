package com.s3scanner.app

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.ext.junit.rules.ActivityScenarioRule
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions.*
import androidx.test.espresso.assertion.ViewAssertions.matches
import androidx.test.espresso.matcher.ViewMatchers.*
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class MainActivityTest {
    @get:Rule
    val activityRule = ActivityScenarioRule(MainActivity::class.java)

    @Test
    fun testInvalidBucketNameShowsError() {
        onView(withId(R.id.editTextBucket))
            .perform(typeText("-invalid-"), closeSoftKeyboard())
        
        onView(withId(R.id.buttonScan))
            .perform(click())

        onView(withText("Invalid bucket name format"))
            .check(matches(isDisplayed()))
    }
}
