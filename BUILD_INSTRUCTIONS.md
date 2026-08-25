# 📱 Bambu Lab AI Monitor - Installer Build Guide

## תרגום לעברית: בנייה של חבילות התקנה

### Windows

#### אפשרות 1: בנייה מהירה (מומלץ למתחילים)
```bash
cd scripts
install_windows.bat
```

זה יהקים:
- Python virtual environment
- התקנת כל התלויות
- יצירת קובץ config.yaml

#### אפשרות 2: בנייה של MSI Installer (למפיצים)
```powershell
PowerShell -ExecutionPolicy Bypass -File scripts/install_windows_msi.ps1
```

#### אפשרות 3: בנייה של NSIS Installer
1. הורד NSIS: https://nsis.sourceforge.io/
2. רן NSIS על `scripts/BambuMonitor.nsi`
3. הפלט: `BambuMonitor-1.0-installer.exe`

---

### Android (APK)

#### דרישות:
- Android Studio או Android SDK Command Line Tools
- JDK 17+
- Minimum Android API 26 (Android 8.0)

#### שלב 1: התקנת Android SDK

**אם אתה בWindows:**
```bash
cd scripts
setup_android_sdk.bat
```

**אם אתה בMac/Linux:**
1. הורד Android Studio: https://developer.android.com/studio
2. אתחול האפליקציה ופתח את תיקית `android/` בה
3. המערכת תורד את SDK באופן אוטומטי

#### שלב 2: בנייה של APK

**אפשרות A - Windows:**
```bash
cd scripts
build_android_apk.bat
```

**אפשרות B - Mac/Linux:**
```bash
./scripts/build_android_release.sh
```

**אפשרות C - Android Studio GUI:**
1. פתח את תיקית `android/` ב-Android Studio
2. בחר `Build > Build APK(s)` מהתפריט
3. ייווצר הקובץ ב: `android/app/build/outputs/apk/debug/app-debug.apk`

#### שלב 3: התקנה בטלפון

**דרך ADB (שורת פקודה):**
```bash
# וודא שהטלפון מחובר ו-USB Debugging מופעל
adb install android/app/build/outputs/apk/debug/app-debug.apk
```

**דרך העתקה ישירה:**
1. העתק את קובץ ה-APK לטלפון
2. פתח את מנהל הקבצים
3. טפקט על ה-APK להתקנה
4. אשר הוראות הגישה

---

## 📁 קבצים שנוצרו

### Windows
```
scripts/
├── install_windows.bat          ← התקנה בסיסית
├── run_windows.bat              ← הפעלת המוניטור
├── build_installer.bat          ← בנייה of PyInstaller EXE
├── install_windows_msi.ps1      ← בנייה of MSI (PowerShell)
├── BambuMonitor.nsi             ← בנייה of NSIS Installer
└── setup_android_sdk.bat        ← הגדרה של Android SDK
```

### Android
```
android/
├── app/
│   ├── src/
│   │   └── main/
│   │       ├── java/com/magic3d/bambumonitor/
│   │       │   └── MainActivity.kt          ← עריכה של SERVER_URL כאן
│   │       ├── AndroidManifest.xml
│   │       └── res/
│   └── build.gradle.kts
├── build.gradle.kts
├── settings.gradle.kts
└── gradlew
```

---

## ⚙️ הגדרה של SERVER_URL

**חשוב:** לפני בנייה של APK, צריך לעדכן את ה-IP של השרת:

1. פתח `android/app/src/main/java/com/magic3d/bambumonitor/MainActivity.kt`
2. חפש את השורה: `private val SERVER_URL = "..."`
3. החלף ב-IP של המחשב שבו רץ `api.py`
   ```kotlin
   // דוגמה:
   private val SERVER_URL = "http://192.168.1.100:8000"
   ```

---

## 🔧 פתרון בעיות

### Windows

**בעיה:** "Python was not found"
- **פתרון:** התקן Python 3.10+ מ https://python.org

**בעיה:** "pip install failed"
- **פתרון:** רן Command Prompt as Administrator

### Android

**בעיה:** "gradlew not found"
- **פתרון:** פתח את `android/` בAndroid Studio, המערכת תורד את gradlew אוטומטית

**בעיה:** "Android SDK not found"
- **פתרון:** הגדר משתנה סביבה `ANDROID_HOME` להצביע לתיקית ה-SDK

**בעיה:** "Build failed - invalid SDK"
- **פתרון:** בAndroid Studio, לך ל Preferences > Appearance & Behavior > System Settings > Android SDK
  ודא שמותקנות:
  - Android API 34
  - Build Tools 34.0.0

---

## 📦 הפצה

### Windows EXE
- אפשר להשתמש בקובץ `.exe` מחמרות החוקי של NSIS ישירות
- או לפרסם בMicrosoft Store

### Android APK
- **עבור משתמשים:** שלח את `app-debug.apk` ישירות
- **עבור Google Play:** צור חשבון developer וחתום על `app-release.aab`

---

## 🔐 חתימה של APK לGoogle Play

```bash
# צור keystore
keytool -genkey -v -keystore my-release-key.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias my-key-alias

# חתום על APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 \
  -keystore my-release-key.keystore \
  app-release.apk my-key-alias
```

---

## 📞 תמיכה

אם יש בעיות:
1. בדוק את ה-README.md
2. וודא שכל התלויות מותקנות
3. פתח Issue ב-GitHub עם log חשוב
