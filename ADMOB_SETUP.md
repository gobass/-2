# إعداد إعلانات AdMob الحقيقية

## 🎯 الحصول على إعلانات حقيقية مدفوعة

### الخطوة 1: إنشاء حساب AdMob
1. اذهب إلى [AdMob Console](https://admob.google.com)
2. سجل دخول بحساب Google
3. اضغط "Get started"
4. أنشئ حساب AdMob جديد

### الخطوة 2: إضافة التطبيق
1. في AdMob Console، اضغط "Add your first app"
2. اختر "Android" أو "iOS" حسب المنصة
3. أدخل اسم التطبيق: "نشمي TF"
4. انسخ App ID

### الخطوة 3: إنشاء وحدات الإعلانات

#### إعلان البانر (Banner):
1. اضغط "Add ad unit"
2. اختر "Banner"
3. اسم الوحدة: "nashmi_banner"
4. انسخ Ad Unit ID

#### إعلان بيني (Interstitial):
1. اضغط "Add ad unit"
2. اختر "Interstitial"
3. اسم الوحدة: "nashmi_interstitial"
4. انسخ Ad Unit ID

#### إعلان مكافآت (Rewarded):
1. اضغط "Add ad unit"
2. اختر "Rewarded"
3. اسم الوحدة: "nashmi_rewarded"
4. انسخ Ad Unit ID

### الخطوة 4: تحديث إعدادات التطبيق

#### في ملف `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-YOUR_APP_ID~YOUR_APP_ID"/>
```

#### في ملف `ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_APP_ID~YOUR_APP_ID</string>
```

#### في ملف `lib/services/ad_service.dart`:
```dart
// استبدل هذه بـ IDs الحقيقية من AdMob
static String get _bannerAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-YOUR_REAL_ID/BANNER_ID'  // من AdMob Console
    : 'ca-app-pub-YOUR_REAL_ID/BANNER_ID_IOS';

static String get _interstitialAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-YOUR_REAL_ID/INTERSTITIAL_ID'
    : 'ca-app-pub-YOUR_REAL_ID/INTERSTITIAL_ID_IOS';

static String get _rewardedAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-YOUR_REAL_ID/REWARDED_ID'
    : 'ca-app-pub-YOUR_REAL_ID/REWARDED_ID_IOS';
```

### الخطوة 5: اختبار الإعلانات

#### Test IDs (للاختبار فقط):
- Banner Android: `ca-app-pub-3940256099942544/6300978111`
- Banner iOS: `ca-app-pub-3940256099942544/2934735716`
- Interstitial Android: `ca-app-pub-3940256099942544/1033173712`
- Interstitial iOS: `ca-app-pub-3940256099942544/4411468910`

**⚠️ مهم:** لا تستخدم Test IDs في الإنتاج النهائي!

### الخطوة 6: تفعيل المدفوعات

#### إعداد المدفوعات:
1. في AdMob Console، اذهب إلى "Payments"
2. أضف معلومات الحساب البنكي
3. أكمل التحقق من الهوية
4. اختر عملة الدفع (USD موصى بها)

#### الحد الأدنى للدفع:
- **USD $100** - الولايات المتحدة
- **EUR €70** - أوروبا  
- **AED 370** - الإمارات
- **SAR 375** - السعودية

### 📊 أنواع الإعلانات في التطبيق:

#### 🟦 إعلانات البانر:
- تظهر في أسفل الشاشات
- دخل ثابت ومستمر
- لا تعطل تجربة المستخدم

#### 🟥 إعلانات بينية:
- تظهر بين الشاشات
- دخل أعلى لكل نقرة
- تظهر عند الانتقال بين الأفلام

#### 🟨 إعلانات المكافآت:
- المستخدم يشاهد ويحصل على مكافأة
- أعلى معدل ربح
- يمكن استخدامها لفتح محتوى مميز

### 💰 تقدير الأرباح:

#### عوامل تؤثر على الأرباح:
- **عدد المستخدمين النشطين**
- **البلد الجغرافي للمستخدمين**  
- **معدل النقر (CTR)**
- **وقت المشاهدة**

#### متوسط الأرباح المتوقعة:
- **1000 مستخدم نشط/يوم:** $1-5/يوم
- **10,000 مستخدم:** $10-50/يوم  
- **100,000 مستخدم:** $100-500/يوم

### 🛡️ سياسات AdMob المهمة:

#### ❌ ممنوع:
- النقر على إعلاناتك الخاصة
- طلب النقر من الآخرين
- إعلانات مضللة أو محتوى غير مناسب
- تطبيقات مقرصنة أو محتوى محظور

#### ✅ مسموح:
- محتوى أصلي وقانوني
- إعلانات في أماكن مناسبة
- تجربة مستخدم جيدة
- المحتوى يتوافق مع سياسات Google

### 🔧 تحسين الإعلانات:

#### لزيادة الأرباح:
1. **مكان الإعلانات:** ضعها في أماكن طبيعية
2. **توقيت العرض:** بين الأنشطة وليس أثناءها
3. **جودة التطبيق:** كلما زادت جودة التطبيق، زادت الأرباح
4. **معدل الاحتفاظ:** المستخدمون النشطون = أرباح أكثر

### 📈 مراقبة الأداء:

#### مؤشرات مهمة:
- **Impressions:** عدد مرات عرض الإعلان
- **Clicks:** عدد النقرات
- **CTR:** معدل النقر (%)
- **eCPM:** الربح لكل 1000 ظهور
- **Revenue:** إجمالي الأرباح

### 🚀 نصائح للنجاح:

1. **تطبيق عالي الجودة** = إعلانات أفضل
2. **مستخدمون راضون** = بقاء أطول = أرباح أكثر
3. **محتوى مميز** = مستخدمون أكثر
4. **تحديثات دورية** = مشاركة أكبر
5. **تجربة مستخدم ممتازة** = معدل احتفاظ عالي

## ⚡ الحالة الحالية:
- **الإعلانات:** مُفعلة مع Test IDs
- **Firebase:** جاهز للاستخدام
- **الإدارة:** عبر Firebase Console فقط
- **الربح:** سيبدأ بعد تفعيل Real IDs

استبدل Test IDs بـ Real IDs لبدء الربح الفعلي! 💰
