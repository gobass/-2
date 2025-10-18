 # حل مشكلة Firestore API

## المشكلة
Exception: Failed to get movies count. PlatformException(firebase_firestore, Cloud Firestore API has not been used in project neshmitf-dashboard before or it is disabled

## الحل الرئيسي - تحميل google-services.json

### الخطوة الأولى والأهم: تحميل ملف التكوين

1. **اذهب إلى Firebase Console:**
   - اذهب إلى: https://console.firebase.google.com
   - اختر مشروع `neshmitf-dashboard`

2. **تحميل ملف التكوين:**
   - اضغط على الإعدادات (الترس) في الشريط الجانبي الأيسر
   - اختر "Project settings"
   - في قسم "Your apps"، اختر التطبيق الخاص بك (Android/iOS)
   - اضغط على "Download google-services.json" للأندرويد
   - احفظ الملف في: `NashmiAdmin/android/app/google-services.json`

3. **إذا لم يكن التطبيق مسجل:**
   - اضغط على "Add app" في قسم "Your apps"
   - اختر Android أو iOS حسب الحاجة
   - أدخل اسم الحزمة (Package name): `com.example.nashmiadmin`
   - اضغط على "Register app"
   - ثم قم بتحميل `google-services.json`

## الحل الثاني - تفعيل Cloud Firestore API

1. **افتح Google Cloud Console:**
   - اذهب إلى: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=neshmitf-dashboard

2. **تفعيل الـ API:**
   - إذا كان الزر "Enable" ظاهر، اضغط عليه
   - إذا كان الـ API مفعل بالفعل، تأكد من أنه مفعل

3. **انتظر:**
   - انتظر 5-10 دقائق حتى ينتشر التفعيل

4. **أعد تشغيل التطبيق:**
   ```bash
   cd NashmiAdmin
   flutter clean
   flutter pub get
   flutter run
   ```

## بدائل إذا استمرت المشكلة:

### 1. تحقق من Firebase Configuration
تأكد من أن ملف `google-services.json` صحيح ومحدث.

### 2. تحقق من Firebase Security Rules
تأكد من أن Firebase Security Rules تسمح بالقراءة/الكتابة.

### 3. تحقق من Firebase Project ID
تأكد من أن Project ID في `firebase_options.dart` مطابق للمشروع.

### 4. استخدم Firebase Console
- اذهب إلى https://console.firebase.google.com
- اختر مشروع neshmitf-dashboard
- اذهب إلى Firestore Database
- إذا لم يكن موجود، أنشئ قاعدة بيانات جديدة

## التحقق من الحل:
بعد تفعيل الـ API، يجب أن تختفي رسالة الخطأ وتعمل الإحصائيات بشكل طبيعي.
