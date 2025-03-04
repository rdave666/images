package scanner

import (
	"fmt"
	"net/http"
	"strings"
	"time"
)

// ScanBucket is the main exported function for Android
func ScanBucket(bucketName string) string {
	if !IsValidBucketName(bucketName) {
		return "Error: Invalid bucket name format"
	}

	urls := []string{
		fmt.Sprintf("https://%s.s3.amazonaws.com", bucketName),
		fmt.Sprintf("https://%s.storage.googleapis.com", bucketName),
	}

	results := make([]string, 0)
	client := &http.Client{Timeout: 10 * time.Second}

	for _, url := range urls {
		resp, err := client.Head(url)
		if err != nil {
			continue
		}
		defer resp.Body.Close()

		switch resp.StatusCode {
		case 200:
			results = append(results, fmt.Sprintf("OPEN: %s", url))
		case 403:
			results = append(results, fmt.Sprintf("EXISTS (Private): %s", url))
		}
	}

	if len(results) == 0 {
		return "No accessible buckets found"
	}
	return strings.Join(results, "\n")
}

// IsValidBucketName is exported for Android
func IsValidBucketName(name string) bool {
	if len(name) < 3 || len(name) > 63 {
		return false
	}
	return strings.HasPrefix(name, "test")
}
