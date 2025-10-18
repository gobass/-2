# دليل توحيد قاعدة البيانات بين NashmiAdmin و Nashmi

## الهدف
توحيد قاعدة البيانات والجداول بين مشروعي NashmiAdmin (لوحة التحكم) و Nashmi (التطبيق الرئيسي) لضمان مشاركة نفس البيانات.

## الإعداد الحالي
- كلا المشروعين يستخدمان Supabase كقاعدة بيانات
- نفس URL الـ Supabase: `https://ohhomkhnzsozopwwnmfw.supabase.co`
- ملفات الإعداد: `assets/supabase_config.json` في كلا المشروعين
- الجداول المشتركة: `movies`, `series`, `ads`, `users`, `episodes`, `categories`

## الخطوات المطلوبة

### 1. التأكد من إعداد Supabase
```json
// assets/supabase_config.json (في كلا المشروعين)
{
  "supabaseUrl": "https://ohhomkhnzsozopwwnmfw.supabase.co",
  "supabaseAnonKey": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9oaG9ta2huenNvem9wd3dubWZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNzQ3NTgsImV4cCI6MjA3MjY1MDc1OH0.O4W8YQB71cOvR67BhIHP-_P6FjnJJgHwEKqDlva8BQA"
}
```

### 2. تشغيل ملفات SQL لإنشاء الجداول
قم بتشغيل الملفات التالية في Supabase SQL Editor:

1. `create_series_table.sql`
2. `create_ads_table.sql`
3. `fix_isseries_column.sql`
4. `fix_missing_columns.sql`
5. `sample_data_insert.sql`

### 3. التأكد من تطابق الخدمات
- `NashmiAdmin/lib/services/supabase_service.dart` - للإدارة الكاملة (CRUD)
- `lib/services/supabase_service.dart` - للقراءة فقط في التطبيق الرئيسي

### 4. إعداد البيئة للإنتاج
```bash
# متغيرات البيئة (اختياري للإنتاج)
SUPABASE_URL=https://ohhomkhnzsozopwwnmfw.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### 5. اختبار التكامل
1. أضف فيلم في NashmiAdmin
2. تأكد من ظهوره في Nashmi
3. اختبر العمليات الأخرى (مسلسلات، إعلانات، إحصائيات)

## المزايا
- ✅ لا تكرار للبيانات
- ✅ تحديث واحد ينعكس على الكل
- ✅ صيانة أسهل
- ✅ أداء أفضل

## ملاحظات مهمة
- NashmiAdmin يستخدم مفتاح الخدمة للعمليات الكاملة
- Nashmi يستخدم مفتاح الوصول العام للقراءة فقط
- جميع الجداول مشتركة ومتزامنة

## استكشاف الأخطاء
إذا واجهت مشاكل:
1. تأكد من صحة `supabase_config.json`
2. تحقق من تشغيل ملفات SQL
3. راجع console logs للأخطاء
4. تأكد من اتصال الإنترنت

## الخطوات التالية
- اختبار شامل لجميع العمليات
- إعداد النسخ الاحتياطي
- مراقبة الأداء
