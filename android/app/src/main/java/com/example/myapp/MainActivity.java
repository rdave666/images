package com.example.myapp;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    private EditText editTextBucket;
    private Button buttonScan;
    private ProgressBar progressBar;
    private TextView textResults;
    private TextView textView;

    // Declare the native method
    public native String scan();

    static {
        System.loadLibrary("s3scanner"); // Load the AAR library
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        editTextBucket = findViewById(R.id.editTextBucket);
        buttonScan = findViewById(R.id.buttonScan);
        progressBar = findViewById(R.id.progressBar);
        textResults = findViewById(R.id.textResults);
        textView = findViewById(R.id.text_view);

        buttonScan.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                startScan();
            }
        });
    }

    private void startScan() {
        progressBar.setVisibility(View.VISIBLE);
        textResults.setText("Scanning...");

        // Simulate a scan operation (replace with actual S3Scanner call)
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(2000); // Simulate scanning time
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                String bucketName = editTextBucket.getText().toString();
                String result = "Scan results for " + bucketName + ":\n" + scan(); // Call the native method

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        progressBar.setVisibility(View.GONE);
                        textResults.setText(result);
                        textView.setText("");
                    }
                });
            }
        }).start();
    }
}
