# دليل إدارة المحتوى عبر Firebase Console

## 🎯 إضافة أفلام ومسلسلات عبر Firebase Console

### خطوات إضافة فيلم جديد:

#### 1. الدخول إلى Firebase Console
- اذهب إلى [Firebase Console](https://console.firebase.google.com)
- اختر مشروع `nashmi-tf`
- اضغط على "Firestore Database"

#### 2. إضافة فيلم جديد
- اضغط "Start collection" إذا لم تكن موجودة
- اسم المجموعة: `movies`
- اضغط "Add document"
- يمكنك ترك "Document ID" فارغ ليتم إنشاؤه تلقائياً

#### 3. الحقول المطلوبة:

```javascript
{
  "title": "اسم الفيلم باللغة العربية",
  "description": "وصف الفيلم أو المسلسل",
  "category": "action|comedy|drama|horror|romance|scifi|thriller",
  "type": "movie|series",
  "imageURL": "رابط صورة الفيلم",
  "videoURL": "رابط الفيديو",
  "year": "2024",
  "duration": "2ساعة 15د",
  "rating": 4.5,
  "viewCount": 0,
  "episodeCount": null, // للمسلسلات فقط: عدد الحلقات
  "createdAt": "timestamp" // اضغط على أيقونة الساعة واختر "Server timestamp"
}
```

### 📝 مثال على فيلم:

```json
{
  "title": "المغامرة الكبرى",
  "description": "فيلم أكشن مثير مليء بالمغامرات والإثارة",
  "category": "action",
  "type": "movie",
  "imageURL": "https://example.com/movie-poster.jpg",
  "videoURL": "https://example.com/movie-video.mp4",
  "year": "2024",
  "duration": "2ساعة 30د",
  "rating": 4.7,
  "viewCount": 0,
  "episodeCount": null,
  "createdAt": "Server timestamp"
}
```

### 📺 مثال على مسلسل:

```json
{
  "title": "مسلسل الأحداث",
  "description": "مسلسل درامي شيق يحكي قصة مؤثرة",
  "category": "drama",
  "type": "series",
  "imageURL": "https://example.com/series-poster.jpg",
  "videoURL": "https://example.com/series-episode1.mp4",
  "year": "2024",
  "duration": "45د/الحلقة",
  "rating": 4.3,
  "viewCount": 0,
  "episodeCount": 24,
  "createdAt": "Server timestamp"
}
```

## 🎯 الفئات المتاحة:

| الفئة | الاسم بالعربية |
|------|--------------|
| action | أكشن |
| comedy | كوميديا |
| drama | دراما |
| horror | رعب |
| romance | رومانسية |
| scifi | خيال علمي |
| thriller | إثارة |

## 📊 إدارة المحتوى:

### ✅ إضافة محتوى جديد:
1. اذهب إلى collection "movies"
2. اضغط "Add document"
3. املأ الحقول المطلوبة
4. اضغط "Save"
5. المحتوى سيظهر فوراً لجميع المستخدمين!

### ✏️ تعديل محتوى موجود:
1. اختر المستند المطلوب
2. اضغط على القلم للتعديل
3. غير المعلومات المطلوبة
4. اضغط "Update"

### 🗑️ حذف محتوى:
1. اختر المستند المطلوب
2. اضغط على سلة المهملات
3. تأكيد الحذف

## 🔒 قواعد الأمان المقترحة:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // قراءة للجميع، كتابة للمديرين فقط
    match /movies/{movieId} {
      allow read: if true;
      allow write: if request.auth != null; // يتطلب مصادقة
    }
    
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 نصائح مهمة:

1. **الصور:** استخدم روابط صور عالية الجودة (300x400 بكسل على الأقل)
2. **الفيديوهات:** تأكد من أن روابط الفيديو تعمل وتدعم التشغيل
3. **التقييم:** اختر قيمة بين 1.0 و 5.0
4. **التاريخ:** استخدم دائماً "Server timestamp" للحقل createdAt
5. **المتابعة:** راقب عدد المشاهدات في Firebase Analytics

## 🚀 بعد الإضافة:
- المحتوى سيظهر فوراً في التطبيق
- سيكون متاح لجميع المستخدمين
- يمكن البحث والفلترة بناءً عليه
- سيظهر في الأقسام المناسبة حسب النوع والفئة

لا تحتاج إعادة تشغيل التطبيق! 🎉
