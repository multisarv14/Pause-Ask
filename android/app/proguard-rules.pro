# PauseAsk R8 rules. Most Firebase / Play libraries ship their own consumer
# rules; these cover the reflective bits that don't.

# flutter_local_notifications stores scheduled notifications with Gson.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod

# ML Kit text recognition (Latin + Devanagari) loads models/classes reflectively.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_text_common.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Firebase Messaging / App Check / Play Integrity.
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.android.play.core.integrity.** { *; }
-dontwarn com.google.android.play.core.**

# speech_to_text / flutter_tts talk to Android services by name.
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }
