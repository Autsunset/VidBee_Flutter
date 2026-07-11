# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Preserve line numbers for crash stacks (helps diagnose minify issues)
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Keep extractor plugin classes
-keep class com.extractor.** { *; }
-keep class com.hiennv.flutter.extractor.** { *; }
-keep class com.ashishpipaliya.extractor.** { *; }

# Keep youtubedl-android (JNI + reflection heavy)
-keep class com.yausername.** { *; }
-keep class com.yausername.youtubedl_android.** { *; }
-dontwarn com.yausername.**

# Keep Flutter embedding / plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep WebView
-keep class * extends android.webkit.WebChromeClient { *; }
-keep class * extends android.webkit.WebViewClient { *; }

# Keep Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Keep FileProvider paths / method channels used by MainActivity
-keep class com.vidbee.vidbee_flutter.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Reflection / JSON attributes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
