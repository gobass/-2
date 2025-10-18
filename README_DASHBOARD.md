# Nashmi Dashboard - لوحة تحكم نشمي

لوحة تحكم لنظام نشمي تعمل على نظام Windows وتتصل بقاعدة بيانات Supabase.

## المتطلبات

- Flutter SDK مع دعم Windows Desktop
- حساب Supabase
- مشروع Supabase مع الجداول المناسبة

## الإعداد

### 1. تثبيت التبعيات

```bash
flutter pub get
```

### 2. تكوين Supabase

1. إنشاء مشروع جديد على [Supabase](https://supabase.com)
2. الحصول على URL و API Key من إعدادات المشروع
3. تحديث ملف `lib/services/supabase_service.dart`:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 3. إنشاء الجداول في Supabase

#### جدول الأفلام (movies)
```sql
CREATE TABLE movies (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  genre TEXT,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  archived BOOLEAN DEFAULT FALSE
);
```

#### جدول الإعلانات (ads)
```sql
CREATE TABLE ads (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  app_id TEXT NOT NULL,
  ad_unit_id TEXT NOT NULL,
  ad_type TEXT NOT NULL, -- 'banner', 'interstitial', 'rewarded'
  is_active BOOLEAN DEFAULT TRUE,
  start_at TIMESTAMP WITH TIME ZONE,
  end_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### جدول المسلسلات (series)
```sql
CREATE TABLE series (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  genre TEXT,
  thumbnail_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## التشغيل

```bash
flutter run -d windows
```

## الميزات

- ✅ إدارة الأفلام (إضافة، تعديل، حذف)
- ✅ إدارة الإعلانات (إضافة، تعديل، حذف)
- ✅ إدارة المسلسلات (إضافة، تعديل، حذف)
- ✅ تحديثات فورية مع Supabase
- ✅ واجهة مستخدم باللغة العربية
- ✅ إحصائيات ومؤشرات أداء

## هيكل المشروع

```
lib/
├── main.dart          # التطبيق الرئيسي
├── services/
│   └── supabase_service.dart  # خدمة الاتصال بـ Supabase
├── views/             # واجهات المستخدم
├── core/              # المكونات الأساسية
└── models/            # نماذج البيانات
```

## الخطوات القادمة

1. إضافة واجهة تسجيل الدخول
2. تطوير واجهات إدارة مفصلة
3. إضافة نظام الصلاحيات
4. تطوير لوحة إحصائيات متقدمة
5. إضافة دعم التحديثات الفورية

## استكشاف الأخطاء وإصلاحها

إذا واجهت أي مشاكل في الاتصال بـ Supabase، تأكد من:
- صحة URL و API Key
- أن الجداول موجودة في قاعدة البيانات
- أن سياسات RLS (Row Level Security) تسمح بالوصول
