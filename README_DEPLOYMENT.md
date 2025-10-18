# دليل النشر على Netlify - نشمي TF

## 🚀 خطوات النشر

### الطريقة الأولى: نشر من GitHub (موصى بها)

1. **ارفع المشروع إلى GitHub:**
   ```bash
   git add .
   git commit -m "إعداد النشر على Netlify"
   git push origin main
   ```

2. **ادخل إلى Netlify:**
   - اذهب إلى [netlify.com](https://netlify.com)
   - سجل دخولك أو أنشئ حساب جديد
   - اضغط على "New site from Git"

3. **اربط مستودع GitHub:**
   - اختر GitHub كمزود
   - ابحث عن مستودع `nashmi_tf`
   - اختر الفرع `main`

4. **إعدادات البناء:**
   - **Base directory:** (اتركه فارغاً)
   - **Build command:** `flutter build web --release`
   - **Publish directory:** `build/web`

5. **متغيرات البيئة (Environment Variables):**
   - لا تحتاج متغيرات بيئة إضافية للنشر الأساسي

6. **انشر الموقع:**
   - اضغط على "Deploy site"
   - انتظر اكتمال البناء (2-3 دقائق)

### الطريقة الثانية: نشر يدوي (Drag & Drop)

1. **بناء المشروع محلياً:**
   ```bash
   flutter build web --release
   ```

2. **ادخل إلى Netlify:**
   - اذهب إلى [netlify.com](https://netlify.com)
   - اضغط على "New site from Git" أو "Deploy manually"

3. **اسحب مجلد build/web:**
   - اسحب مجلد `build/web` إلى منطقة الإسقاط
   - انتظر اكتمال النشر

## ⚙️ إعدادات متقدمة

### متغيرات البيئة (اختيارية)

إذا كنت تريد إعداد متغيرات بيئة للإنتاج:

```
FIREBASE_API_KEY=your_production_api_key
FIREBASE_PROJECT_ID=your_project_id
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
```

### إعدادات الأمان

الملف `netlify.toml` يحتوي على إعدادات الأمان التالية:
- رؤوس أمان HTTP
- ضغط وتحسين الملفات
- إعادة توجيهات SPA
- تحكم في التخزين المؤقت

## 🔧 استكشاف الأخطاء

### مشكلة: خطأ في Firebase
- تأكد من صحة إعدادات Firebase في `web/firebase-config.js`
- تحقق من أن مشروع Firebase يدعم المجال الجديد

### مشكلة: خطأ في البناء
- تأكد من تثبيت Flutter SDK
- تحقق من إصدار Flutter: `flutter --version`
- جرب بناء المشروع محلياً أولاً

### مشكلة: الموقع لا يعمل بعد النشر
- تحقق من Console المتصفح للأخطاء
- تأكد من أن جميع الملفات تم رفعها
- تحقق من إعدادات Firebase

## 📱 اختبار التطبيق

بعد النشر:

1. **افتح الموقع** في متصفحك
2. **تحقق من الوظائف الأساسية:**
   - تحميل الصفحة الرئيسية
   - البحث عن الأفلام
   - تشغيل الفيديو
   - التنقل بين الصفحات

3. **اختبر على الأجهزة المختلفة:**
   - الهاتف المحمول
   - التابلت
   - سطح المكتب

## 🔄 تحديث التطبيق

لتحديث التطبيق:

1. **ادفع التغييرات إلى GitHub:**
   ```bash
   git add .
   git commit -m "تحديث جديد"
   git push origin main
   ```

2. **Netlify سيقوم بالنشر تلقائياً** خلال دقائق

## 📞 الدعم

إذا واجهت مشاكل:
- تحقق من [وثائق Netlify](https://docs.netlify.com/)
- راجع [وثائق Flutter Web](https://docs.flutter.dev/development/platform-integration/web)
- تحقق من Console المتصفح للأخطاء

---

**🎉 مبروك! تطبيق نشمي TF جاهز للنشر على Netlify!**
