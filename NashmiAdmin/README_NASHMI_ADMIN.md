# نشمي - لوحة التحكم الإدارية

لوحة تحكم شاملة لإدارة محتوى تطبيق نشمي، مبنية بـ Flutter للويندوز ومتكاملة مع Supabase.

## المميزات الرئيسية

- **إدارة الأفلام**: CRUD كامل مع رفع البوسترات
- **إدارة الإعلانات**: دعم AdMob والإعلانات المخصصة
- **إدارة المستخدمين**: نظام صلاحيات (مدير، محرر)
- **إحصائيات حية**: عرض إحصائيات المحتوى والمستخدمين
- **واجهة عربية**: تصميم متكامل باللغة العربية

## التقنيات المستخدمة

- **Flutter**: واجهة المستخدم
- **Supabase**: قاعدة البيانات والمصادقة وتخزين الملفات
- **GetX**: إدارة الحالة والتوجيه

## هيكل المشروع

```
lib/
├── core/
│   └── router/          # التوجيه والتنقل
├── services/            # خدمات Supabase والمصادقة
├── views/               # واجهات المستخدم
│   ├── movies/          # إدارة الأفلام
│   ├── ads/            # إدارة الإعلانات
│   ├── series/          # إدارة المسلسلات
│   ├── users/           # إدارة المستخدمين
│   └── dashboard.dart   # لوحة التحكم الرئيسية
```

## التثبيت والإعداد

### 1. متطلبات النظام
- Flutter SDK 3.24+
- Android Studio / VS Code
- Supabase Project

### 2. إعداد Supabase
1. إنشاء مشروع جديد في Supabase Dashboard
2. الحصول على URL و Anon Key من Project Settings > API
3. إعداد قواعد Row Level Security (RLS) للجداول
4. تفعيل Storage Bucket للملفات

### 3. تثبيت الاعتماديات
```bash
flutter pub add firebase_core
flutter pub add cloud_firestore
flutter pub add firebase_storage
flutter pub add firebase_auth
flutter pub add get
flutter pub add file_picker
```

### 4. تهيئة التطبيق
تعديل ملف `main.dart` بإضافة معلومات Firebase الخاصة بك:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "your-api-key",
    appId: "your-app-id",
    messagingSenderId: "your-sender-id",
    projectId: "your-project-id",
    storageBucket: "your-storage-bucket",
  ),
);
```

## قواعد الأمان

### Firestore Rules
انظر ملف `firebase_security_rules.txt` للقواعد الكاملة.

### Storage Rules
يجب تطبيق قواعد الأمان المناسبة لحماية الملفات.

## الاستخدام

### تسجيل الدخول
- البريد الإلكتروني: `admin@nashmi.com`
- كلمة المرور: `123`

### إضافة فيلم جديد
1. الانتقال إلى صفحة الأفلام
2. النقر على "إضافة فيلم جديد"
3. ملء البيانات المطلوبة
4. رفع صورة البوستر
5. حفظ البيانات

### إدارة الإعلانات
1. الانتقال إلى صفحة الإعلانات
2. اختيار نوع المزود (AdMob أو مخصص)
3. إدخال بيانات الإعلان
4. تحديد فترة العرض
5. حفظ الإعلان

## التغليف للنشر

### بناء تطبيق Windows
```bash
flutter build windows --release
```

### موقع الملف التنفيذي
```
build/windows/runner/Release/nashmi_admin.exe
```

## هيكل قاعدة البيانات

### مجموعة الأفلام (movies)
```json
{
  "title": "string",
  "slug": "string",
  "description": "string",
  "categories": ["array"],
  "year": "number",
  "duration": "number",
  "posterUrl": "string",
  "videoUrl": "string",
  "isActive": "boolean",
  "isSeries": "boolean",
  "tags": ["array"],
  "views": "number",
  "archived": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### مجموعة الإعلانات (ads)
```json
{
  "title": "string",
  "provider": "string",
  "appId": "string",
  "adUnitId": "string",
  "adType": "string",
  "position": "string",
  "mediaUrl": "string",
  "link": "string",
  "frequency": "number",
  "weight": "number",
  "isActive": "boolean",
  "startAt": "timestamp",
  "endAt": "timestamp",
  "createdAt": "timestamp"
}
```

## استكشاف الأخطاء

### مشاكل الاتصال بـ Firebase
- التحقق من معلومات التهيئة
- التأكد من تفعيل الخدمات في Firebase Console

### مشاكل رفع الملفات
- التحقق من أذونات Storage
- التأكد من حجم الملف (أقصى 5MB للبوسترات)

### مشاكل الصلاحيات
- التأكد من دور المستخدم في `usersMeta`

## الدعم

للأسئلة والدعم التقني، يرجى التواصل عبر:
- البريد الإلكتروني: support@nashmi.com
- الواتساب: +962798393520

## التحديثات القادمة

- [ ] دعم الاستيراد/التصدير بـ CSV
- [ ] إحصائيات متقدمة
- [ ] نظام الإشعارات
- [ ] نسخ احتياطي تلقائي
- [ ] واجهة متعددة اللغات

---

**نشمي** - © 2024 جميع الحقوق محفوظة
