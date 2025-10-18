# قاعدة البيانات Supabase - مخطط الجداول

هذا الملف يحتوي على وصف شامل لجداول قاعدة البيانات المستخدمة في مشروع Nashmi Admin، مع تفاصيل الأعمدة والحقول لكل جدول.

## الجداول الرئيسية

| الجدول | الوصف | الأعمدة |
|--------|--------|----------|
| **movies** | يحتوي على بيانات الأفلام | `id` (UUID, Primary Key), `title` (TEXT), `slug` (TEXT), `description` (TEXT), `categories` (ARRAY), `year` (INTEGER), `duration` (INTEGER), `posterUrl` (TEXT), `videoUrl` (TEXT), `isActive` (BOOLEAN), `tags` (ARRAY), `views` (INTEGER), `createdat` (TIMESTAMP) |
| **series** | يحتوي على بيانات المسلسلات | `id` (UUID, Primary Key), `title` (TEXT), `slug` (TEXT), `description` (TEXT), `categories` (ARRAY), `year` (INTEGER), `duration` (INTEGER), `posterUrl` (TEXT), `video_url` (TEXT), `tags` (ARRAY), `views` (INTEGER), `rating` (FLOAT), `total_episodes` (INTEGER), `isSeries` (BOOLEAN), `createdat` (TIMESTAMP) |
| **episodes** | يحتوي على بيانات حلقات المسلسلات | `id` (UUID, Primary Key), `series_id` (UUID, Foreign Key to series.id), `episode_number` (INTEGER), `title` (TEXT), `video_url` (TEXT), `created_at` (TIMESTAMP), `posters` (TEXT), `description` (TEXT), `duration` (INTEGER), `views` (INTEGER), `is_active` (BOOLEAN), `updated_at` (TIMESTAMP) |
| **ads** | يحتوي على بيانات الإعلانات | `id` (UUID, Primary Key), `title` (TEXT), `description` (TEXT), `imageUrl` (TEXT), `videoUrl` (TEXT), `targetUrl` (TEXT), `start_at` (TIMESTAMP), `end_at` (TIMESTAMP), `adMobAppId` (TEXT), `adUnitId` (TEXT), `is_active` (BOOLEAN), `frequency` (INTEGER), `weight` (INTEGER), `createdat` (TIMESTAMP) |
| **users** | يحتوي على بيانات المستخدمين | `id` (UUID, Primary Key), `name` (TEXT), `email` (TEXT), `status` (TEXT), `createdAt` (TIMESTAMP), `updatedAt` (TIMESTAMP) |
| **categories** | يحتوي على قائمة التصنيفات | `name` (TEXT, Primary Key), `created_at` (TIMESTAMP) |

## علاقات الجداول

- **episodes.series_id** → **series.id** (علاقة واحد إلى متعدد مع قيد خارجي: كل حلقة تنتمي إلى مسلسل واحد، مع حذف تلقائي عند حذف المسلسل)
- **movies.categories** → **categories.name** (علاقة متعدد إلى متعدد: الأفلام يمكن أن تنتمي إلى تصنيفات متعددة - يتم التحقق من صحة البيانات من خلال التطبيق)
- **series.categories** → **categories.name** (علاقة متعدد إلى متعدد: المسلسلات يمكن أن تنتمي إلى تصنيفات متعددة - يتم التحقق من صحة البيانات من خلال التطبيق)
- الجداول الأخرى (ads, users) مستقلة ولا تحتوي على علاقات خارجية مباشرة

### إضافة القيود الخارجية

لإضافة القيود الخارجية الحقيقية إلى قاعدة البيانات، قم بتنفيذ ملف `add_foreign_keys.sql`:

```sql
-- Add foreign key constraint for episodes.series_id -> series.id
ALTER TABLE episodes
ADD CONSTRAINT fk_episodes_series_id
FOREIGN KEY (series_id) REFERENCES series(id) ON DELETE CASCADE;
```

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

#### استرجاع البيانات من الجداول
```bash
# استرجاع جميع الأفلام
supabase db dump --data-only --table movies > movies_data.sql

# استرجاع جميع المسلسلات
supabase db dump --data-only --table series > series_data.sql

# استرجاع جميع الإعلانات
supabase db dump --data-only --table ads > ads_data.sql

# استرجاع جميع الحلقات
supabase db dump --data-only --table episodes > episodes_data.sql

# استرجاع جميع المستخدمين
supabase db dump --data-only --table users > users_data.sql

# استرجاع جميع التصنيفات
supabase db dump --data-only --table categories > categories_data.sql
```

لاسترجاع البيانات باستخدام استعلامات SQL، قم بتنفيذ ملف `retrieve_data.sql` في Supabase SQL Editor.

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

## ملاحظات مهمة

- جميع الجداول تستخدم UUID كمفتاح أساسي
- الجداول movies و series تحتويان على مصفوفات للتصنيفات والكلمات المفتاحية
- جدول episodes مرتبط بجدول series عبر series_id
- الإعلانات لها تواريخ بداية ونهاية للتحكم في العرض
- المستخدمين لديهم حالات مختلفة (نشط، غير نشط، محظور)
- جميع الجداول تحتوي على حقول timestamps للتتبع
