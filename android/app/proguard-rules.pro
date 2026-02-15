# Сохраняем Google Mobile Ads SDK
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Сохраняем Firebase
-keep class com.google.firebase.** { *; }

# Предотвращаем обфускацию моделей данных (если есть)
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}