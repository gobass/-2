# إعداد Firebase لنشمي TF

## 🎯 لجعل الأفلام تظهر لجميع المستخدمين

### الخطوة 1: إنشاء مشروع Firebase
1. اذهب إلى [Firebase Console](https://console.firebase.google.com)
2. اضغط "Create a project" أو "إنشاء مشروع"
3. أدخل اسم المشروع: `nashmi-tf`
4. اختر الإعدادات المناسبة واكمل الإعداد

### الخطوة 2: إعداد Firestore Database
1. في Firebase Console، اذهب إلى "Firestore Database"
2. اضغط "Create database"
3. اختر "Start in test mode" للبداية
4. اختر المنطقة الأقرب لك

### الخطوة 3: إعداد Web App
1. في Firebase Console، اذهب إلى "Project Settings"
2. في تبويب "Your apps"، اضغط على رمز الويب `</>`
3. أدخل اسم التطبيق: `nashmi-tf-web`
4. انسخ إعدادات Firebase Config

### الخطوة 4: تحديث إعدادات التطبيق
1. افتح ملف `web/firebase-config.js`
2. استبدل المعلومات بإعدادات مشروعك:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",           // من Firebase Console
  authDomain: "nashmi-tf.firebaseapp.com",
  projectId: "nashmi-tf",
  storageBucket: "nashmi-tf.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

### الخطوة 5: تفعيل Firebase في التطبيق
في ملف `lib/services/firebase_service.dart`، غير:
```dart
static bool _isFirebaseEnabled = false;
```
إلى:
```dart
static bool _isFirebaseEnabled = true;
```

### الخطوة 6: إزالة التعليق من Firebase في main.dart
```dart
// إزالة التعليق من هذه الأسطر:
try {
  await Firebase.initializeApp();
  print('Firebase initialized successfully');
} catch (e) {
  print('Failed to initialize Firebase: $e');
}
```

## 🎬 كيفية إضافة الأفلام

### الطريقة الموصى بها: لوحة التحكم في التطبيق
1. شغل التطبيق
2. اضغط على "الدخول إلى لوحة التحكم"
3. سجل دخول بـ:
   - المستخدم: `admin`
   - كلمة المرور: `admin123`
4. اذهب إلى تبويب "إضافة محتوى"
5. أضف الفيلم/المسلسل
6. سيظهر لجميع المستخدمين فوراً!

### الطريقة البديلة: Firebase Console
1. اذهب إلى Firebase Console
2. افتح Firestore Database
3. أنشئ collection اسمه `movies`
4. أضف document جديد بالحقول المطلوبة

## 🔒 الأمان

### قواعد Firestore للبداية:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قراءة للجميع، كتابة للمديرين فقط
    match /movies/{movieId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## ✅ بعد الإعداد
- الأفلام المُضافة من لوحة التحكم ستظهر لجميع المستخدمين
- يمكن إدارة المحتوى من التطبيق مباشرة
- البيانات محفوظة في الكلاود
- تحديثات فورية لجميع المستخدمين

## 🚨 ملاحظة مهمة
حالياً Firebase معطل، لذلك البيانات محلية فقط. بعد تفعيله، ستصبح البيانات مشتركة بين جميع المستخدمين.
