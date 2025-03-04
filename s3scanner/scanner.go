package s3scanner

import (
	"fmt"
	"net/http"
	"time"
)

// ScanResult represents the result of scanning a single bucket
type ScanResult struct {
	BucketName   string
	IsPublic     bool
	ErrorMessage string
}

// Scanner handles S3 bucket scanning operations
type Scanner struct {
	client *http.Client
}

// NewScanner creates a new Scanner instance
func NewScanner() *Scanner {
	return &Scanner{
		client: &http.Client{
			Timeout: time.Second * 10,
		},
	}
}

// ScanBucket checks if a bucket is publicly accessible
func (s *Scanner) ScanBucket(bucketName string) *ScanResult {
	url := fmt.Sprintf("https://%s.s3.amazonaws.com", bucketName)

	resp, err := s.client.Head(url)
	if err != nil {
		return &ScanResult{
			BucketName:   bucketName,
			IsPublic:     false,
			ErrorMessage: err.Error(),
		}
	}
	defer resp.Body.Close()

	return &ScanResult{
		BucketName: bucketName,
		IsPublic:   resp.StatusCode == http.StatusOK,
	}
}
