package com.s3scanner.app

import org.junit.Test
import org.junit.Assert.*

class S3ScannerWrapperTest {
    private val wrapper = S3ScannerWrapper()

    @Test
    fun testValidBucketNames() {
        assertTrue(wrapper.isValidBucketName("my-bucket-123"))
        assertTrue(wrapper.isValidBucketName("mybucket"))
        assertTrue(wrapper.isValidBucketName("my.bucket.123"))
    }

    @Test
    fun testInvalidBucketNames() {
        assertFalse(wrapper.isValidBucketName(""))
        assertFalse(wrapper.isValidBucketName("MY-BUCKET"))
        assertFalse(wrapper.isValidBucketName("-mybucket"))
        assertFalse(wrapper.isValidBucketName("mybucket-"))
    }

    @Test(expected = S3ScannerException::class)
    fun testValidateEmptyResponse() {
        wrapper.validateResponse("")
    }
}
