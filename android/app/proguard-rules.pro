-keepclasseswithmembers class com.s3scanner.app.S3ScannerWrapper {
    native <methods>;
}

-keep class com.s3scanner.app.S3ScannerException

-dontwarn java.lang.invoke.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
