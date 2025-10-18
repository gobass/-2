# دليل إعداد إعلانات Google AdMob للتطبيق

## المشكلة الحالية
تطبيقك يستخدم معرفات إعلانات تجريبية (Test IDs) بدلاً من معرفات الإنتاج الحقيقية، لذلك لا تظهر الإعلانات في التطبيق المُنشر.

## الحل: الحصول على معرفات إعلانات حقيقية

### الخطوة 1: التحقق من وجود حساب AdMob
1. اذهب إلى [Google AdMob Console](https://apps.admob.com/)
2. سجل دخولك بحساب Google
3. إذا لم يكن لديك حساب، أنشئ واحد جديد

### الخطوة 2: إضافة تطبيقك إلى AdMob Console
1. في AdMob Console، اضغط على "Add app"
2. اختر "Android" أو "iOS"
3. أدخل اسم التطبيق: "نشمي TF"
4. أدخل اسم الحزمة (Package name):
   - Android: `com.example.nashmi_tf` (أو اسم الحزمة الحقيقي)
   - iOS: `com.example.nashmi-tf` (إذا كان لديك تطبيق iOS)
5. اضغط على "Add"

### الخطوة 3: إنشاء Ad Units (وحدات الإعلانات)

#### للإعلانات البانر (Banner Ads):
1. في AdMob Console، اذهب إلى "Ad units" في القائمة الجانبية
2. اضغط على "Create Ad Unit"
3. اختر "Banner"
4. أدخل اسم الإعلان: "Banner Android"
5. اختر حجم البانر: "Banner (320x50)" أو "Large Banner (320x100)"
6. اضغط على "Create ad unit"
7. **انسخ معرف الإعلان** الذي سيظهر بالصيغة: `ca-app-pub-XXXXXXXXXX/XXXXXXXXXX`

#### للإعلانات بينية (Interstitial Ads):
1. اضغط على "Create Ad Unit"
2. اختر "Interstitial"
3. أدخل اسم الإعلان: "Interstitial Android"
4. اختر تنسيق: "Full screen"
5. اضغط على "Create ad unit"
6. **انسخ معرف الإعلان**

#### للإعلانات المكافئة (Rewarded Ads):
1. اضغط على "Create Ad Unit"
2. اختر "Rewarded"
3. أدخل اسم الإعلان: "Rewarded Android"
4. اختر تنسيق: "Full screen"
5. اضغط على "Create ad unit"
6. **انسخ معرف الإعلان**

### الخطوة 4: تحديث قاعدة البيانات

#### استخدم الملف `update_production_admob_config.sql`:
1. افتح الملف `update_production_admob_config.sql`
2. استبدل القيم التالية بمعرفاتك الحقيقية:

```sql
-- استبدل هذا:
'YOUR_REAL_BANNER_AD_UNIT_ID_ANDROID'

-- بهذا (معرف البانر الذي نسخته):
'ca-app-pub-1234567890123456/1234567890'
```

3. استبدل جميع القيم:
   - `YOUR_REAL_BANNER_AD_UNIT_ID_ANDROID` → معرف بانر Android
   - `YOUR_REAL_INTERSTITIAL_AD_UNIT_ID_ANDROID` → معرف بيني Android
   - `YOUR_REAL_REWARDED_AD_UNIT_ID_ANDROID` → معرف مكافآت Android
   - ونفس الشيء للـ iOS إذا كان لديك

4. شغل الملف في Supabase SQL Editor

### الخطوة 5: التحقق من الإعدادات

#### شغل ملف التشخيص:
1. افتح `diagnose_ads_status.sql`
2. شغله في Supabase SQL Editor
3. تحقق من النتائج:
   - ✅ يجب أن ترى "PRODUCTION ID" بدلاً من "TEST ID"
   - ✅ يجب أن ترى "VALID APP ID" أو "VALID AD UNIT ID"

### الخطوة 6: إعادة بناء التطبيق

1. بعد تحديث قاعدة البيانات، أعد بناء APK جديد:
   ```bash
   flutter build apk --release
   ```

2. وقع التطبيق بمفتاح الإنتاج (Production Keystore)

3. انشر النسخة الجديدة

## ملاحظات مهمة

### وقت ظهور الإعلانات:
- قد يستغرق ظهور الإعلانات **24-48 ساعة** بعد إنشاء Ad Units
- الإعلانات لن تظهر في وضع التطوير (debug mode)
- تأكد من أن التطبيق مُوقع للإنتاج

### اختبار الإعلانات:
لاختبار الإعلانات قبل النشر:
1. استخدم جهاز حقيقي (ليس emulator)
2. شغل التطبيق من APK مُوقع
3. انتظر بضع دقائق لتحميل الإعلانات

### استكشاف الأخطاء:

#### إذا لم تظهر الإعلانات:
1. تحقق من ملف التشخيص `diagnose_ads_status.sql`
2. تأكد من أن التطبيق ليس في وضع debug
3. تحقق من أن Ad Units مُفعلة في AdMob Console
4. انتظر 24 ساعة على الأقل

#### رسائل الخطأ الشائعة:
- `"No ad config found"` → تحقق من قاعدة البيانات
- `"Ad failed to load"` → تحقق من معرفات الإعلانات
- `"Ads not supported on this platform"` → تحقق من AndroidManifest.xml

## الخطوات التالية

1. **هل أنشأت حساب AdMob؟**
2. **هل أضفت تطبيقك إلى AdMob Console؟**
3. **هل حصلت على معرفات الإعلانات الحقيقية؟**
4. **هل تريد مني مساعدتك في تحديث ملف SQL بالمعرفات الصحيحة؟**

## روابط مفيدة

- [Google AdMob Console](https://apps.admob.com/)
- [دليل AdMob الرسمي](https://developers.google.com/admob)
- [توثيق Flutter AdMob](https://pub.dev/packages/google_mobile_ads)

---

**ملاحظة**: احتفظ بمعرفات الإعلانات في مكان آمن ولا تشاركها مع أي شخص. هذه المعرفات مرتبطة بحسابك في Google AdMob.
