package com.s3scanner.app

import android.os.Bundle
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import android.view.View
import android.widget.ProgressBar
import android.text.method.ScrollingMovementMethod

class MainActivity : AppCompatActivity() {
    private lateinit var scanner: S3ScannerWrapper
    private lateinit var progressBar: ProgressBar
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        scanner = S3ScannerWrapper()
        
        val buttonScan = findViewById<Button>(R.id.buttonScan)
        val editTextBucket = findViewById<EditText>(R.id.editTextBucket)
        val textResults = findViewById<TextView>(R.id.textResults)
        progressBar = findViewById(R.id.progressBar)
        
        textResults.movementMethod = ScrollingMovementMethod()
        
        buttonScan.setOnClickListener {
            val bucketName = editTextBucket.text.toString()
            if (scanner.isValidBucketName(bucketName)) {
                setLoading(true)
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val result = scanner.scanBucket(bucketName)
                        withContext(Dispatchers.Main) {
                            textResults.text = result
                            setLoading(false)
                        }
                    } catch (e: S3ScannerException) {
                        withContext(Dispatchers.Main) {
                            handleError(e)
                            setLoading(false)
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            handleError(e)
                            setLoading(false)
                        }
                    }
                }
            } else {
                Snackbar.make(it, "Invalid bucket name format", Snackbar.LENGTH_LONG).show()
            }
        }
    }
    
    private fun setLoading(isLoading: Boolean) {
        progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
        buttonScan.isEnabled = !isLoading
    }
    
    private fun handleError(e: Exception) {
        val message = when (e) {
            is S3ScannerException -> "Scanner error: ${e.message}"
            else -> "Unexpected error: ${e.message}"
        }
        Snackbar.make(buttonScan, message, Snackbar.LENGTH_LONG).show()
    }
}
