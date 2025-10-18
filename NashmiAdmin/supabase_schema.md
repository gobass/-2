# قاعدة البيانات Supabase - مخطط الجداول

هذا الملف يحتوي على وصف شامل لجداول قاعدة البيانات المستخدمة في مشروع Nashmi Admin، مع تفاصيل الأعمدة والحقول لكل جدول.

## الجداول الرئيسية

| الجدول | الوصف | الأعمدة |
|--------|--------|----------|
| **movies** | يحتوي على بيانات الأفلام | `id` (UUID, Primary Key), `title` (TEXT), `slug` (TEXT), `description` (TEXT), `categories` (ARRAY), `year` (INTEGER), `duration` (INTEGER), `posterUrl` (TEXT), `videoUrl` (TEXT), `isActive` (BOOLEAN), `tags` (ARRAY), `views` (INTEGER), `createdat` (TIMESTAMP) |
| **series** | يحتوي على بيانات المسلسلات | `id` (UUID, Primary Key), `title` (TEXT), `slug` (TEXT), `description` (TEXT), `categories` (ARRAY), `year` (INTEGER), `duration` (INTEGER), `posterUrl` (TEXT), `video_url` (TEXT), `tags` (ARRAY), `views` (INTEGER), `rating` (FLOAT), `total_episodes` (INTEGER), `isSeries` (BOOLEAN), `createdat` (TIMESTAMP) |
| **episodes** | يحتوي على بيانات حلقات المسلسلات | `id` (UUID, Primary Key), `series_id` (UUID, Foreign Key), `episode_number` (INTEGER), `title` (TEXT), `video_url` (TEXT), `embed_code` (TEXT), `created_at` (TIMESTAMP), `posters` (TEXT), `description` (TEXT), `duration` (INTEGER), `views` (INTEGER), `is_active` (BOOLEAN), `updated_at` (TIMESTAMP) |
| **ads** | يحتوي على بيانات الإعلانات | `id` (UUID, Primary Key), `title` (TEXT), `description` (TEXT), `imageUrl` (TEXT), `videoUrl` (TEXT), `targetUrl` (TEXT), `start_at` (TIMESTAMP), `end_at` (TIMESTAMP), `adMobAppId` (TEXT), `adUnitId` (TEXT), `is_active` (BOOLEAN), `frequency` (INTEGER), `weight` (INTEGER), `createdat` (TIMESTAMP) |
| **users** | يحتوي على بيانات المستخدمين | `id` (UUID, Primary Key), `name` (TEXT), `email` (TEXT), `status` (TEXT), `createdAt` (TIMESTAMP), `updatedAt` (TIMESTAMP) |
| **categories** | يحتوي على قائمة التصنيفات | `name` (TEXT, Primary Key), `created_at` (TIMESTAMP) |

## معلومات Supabase CLI

### تثبيت Supabase CLI

```bash
npm install -g supabase
```

### تسجيل الدخول

```bash
supabase login
```

### ربط المشروع

```bash
supabase link --project-ref ohhomkhnzsozopwwnmfw
```

### إدارة قاعدة البيانات

#### عرض حالة المشروع
```bash
supabase status
```

#### تشغيل الخادم المحلي
```bash
supabase start
```

#### إيقاف الخادم المحلي
```bash
supabase stop
```

#### عرض السجلات
```bash
supabase logs
```

### إدارة الجداول والمخطط

#### إنشاء جدول جديد
```bash
supabase db push
```

#### تحديث المخطط من الملفات المحلية
```bash
supabase db diff
```

#### إعادة تعيين قاعدة البيانات
```bash
supabase db reset
```

#### تصدير المخطط
```bash
supabase db dump --schema public > schema.sql
```

### إدارة البيانات

#### إدراج بيانات تجريبية
```bash
supabase db seed
```

#### نسخ احتياطي للبيانات
```bash
supabase db dump --data-only > data.sql
```

### النشر والإنتاج

#### نشر التغييرات
```bash
supabase db push --include-all
```

#### عرض معلومات المشروع
```bash
supabase projects list
```

### أوامر مفيدة أخرى

#### إنشاء migration جديد
```bash
supabase migration new migration_name
```

#### تشغيل migrations
```bash
supabase db push
```

#### إدارة الوظائف (Edge Functions)
```bash
supabase functions deploy function_name
```

#### إدارة التخزين
```bash
supabase storage ls
```

## إضافة أقسام جديدة ومحتوى ديناميكي

### إدارة التصنيفات (Categories)

يمكنك إضافة تصنيفات جديدة بسهولة من خلال التطبيق:

1. **من واجهة التطبيق:**
   - انتقل إلى قسم "التصنيفات" في التطبيق
   - اضغط على زر "إضافة تصنيف جديد"
   - أدخل اسم التصنيف الجديد
   - احفظ التغييرات

2. **عبر Supabase Dashboard:**
   ```sql
   INSERT INTO categories (name, created_at)
   VALUES ('تصنيف جديد', NOW());
   ```

3. **عبر Supabase CLI:**
   ```bash
   supabase db reset  # لإعادة تعيين قاعدة البيانات
   # أو تحديث البيانات مباشرة
   ```

### إضافة أنواع محتوى جديدة

لإضافة أنواع محتوى جديدة (مثل أفلام، مسلسلات، إعلانات):

1. **إضافة فيلم جديد:**
   - انتقل إلى قسم "الأفلام"
   - اضغط "إضافة فيلم جديد"
   - املأ البيانات المطلوبة (العنوان، الوصف، الفيديو، إلخ)
   - اختر التصنيفات المناسبة
   - احفظ الفيلم

2. **إضافة مسلسل جديد:**
   - انتقل إلى قسم "المسلسلات"
   - اضغط "إضافة مسلسل جديد"
   - املأ البيانات الأساسية
   - أضف الحلقات من قسم إدارة الحلقات

3. **إضافة إعلان جديد:**
   - انتقل إلى قسم "الإعلانات"
   - اضغط "إضافة إعلان جديد"
   - أدخل تفاصيل AdMob وتواريخ العرض

### إدارة المحتوى الديناميكية

- **التحديث:** يمكن تعديل أي محتوى موجود بالضغط على زر "تعديل"
- **الحذف:** احذف المحتوى غير المرغوب به بسهولة
- **البحث والتصفية:** ابحث عن المحتوى حسب العنوان أو التصنيف
- **الإحصائيات:** راقب أداء المحتوى من قسم التقارير

## ملاحظات مهمة

- جميع الجداول تستخدم UUID كمفتاح أساسي
- الجداول movies و series تحتويان على مصفوفات للتصنيفات والكلمات المفتاحية
- جدول episodes مرتبط بجدول series عبر series_id
- الإعلانات لها تواريخ بداية ونهاية للتحكم في العرض
- المستخدمين لديهم حالات مختلفة (نشط، غير نشط، محظور)
- جميع الجداول تحتوي على حقول timestamps للتتبع
