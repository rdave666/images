package com.example.s3scanner

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.s3scanner.databinding.ActivityMainBinding
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import s3scanner.Scanner
import s3scanner.ScanResult

class MainActivity : AppCompatActivity() {
    private lateinit var binding: ActivityMainBinding
    private val scanner = Scanner.NewScanner()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.buttonScan.setOnClickListener {
            startScan()
        }
    }

    private fun startScan() {
        val bucketNames = binding.editTextBuckets.text.toString()
            .split("\n")
            .filter { it.isNotBlank() }
            .toTypedArray()

        if (bucketNames.isEmpty()) {
            Toast.makeText(this, "Please enter bucket names", Toast.LENGTH_SHORT).show()
            return
        }

        binding.progressBar.visibility = View.VISIBLE
        binding.buttonScan.isEnabled = false

        CoroutineScope(Dispatchers.IO).launch {
            scanner.StartScan(bucketNames.toList())
            
            runOnUiThread {
                binding.progressBar.visibility = View.GONE
                binding.buttonScan.isEnabled = true
                displayResults(scanner.Results)
            }
        }
    }

    private fun displayResults(results: List<ScanResult>) {
        val resultText = StringBuilder()
        results.forEach { result ->
            resultText.append("Bucket: ${result.BucketName}\n")
            resultText.append("Public: ${result.IsPublic}\n")
            resultText.append("Permissions: ${result.Permissions}\n")
            if (result.ErrorMessage.isNotEmpty()) {
                resultText.append("Error: ${result.ErrorMessage}\n")
            }
            resultText.append("\n")
        }
        binding.textViewResults.text = resultText.toString()
    }
}
