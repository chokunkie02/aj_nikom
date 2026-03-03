# ?? SETUP INSTRUCTIONS FOR TEAM MEMBERS

## ?? **IMPORTANT: ??????????????????????? Performance ?????????????**

---

## **??????????????????? (FPS ???):**

? **Debug Build** ?????????? (?? debug symbols)  
? **Wrong OpenCV path** (link ????? old/wrong library)  
? **Missing optimization flags** (???????????)

? **???????:** ??????? Release Build + Optimization Flags

---

## **?? Setup Procedure (?? 1 ?????????????)**

### **Step 1: Run Setup Script**

```powershell
# ???? Command Prompt ?? project folder
cd "C:\Users\YourName\source\repos\project_opencv_ajsum_last"

# Run setup script
setup_opencv.bat
```

**Script ??:**
- ? ?? OpenCV path
- ? ???? OPENCV_DIR environment variable
- ? ??????? configuration

---

### **Step 2: ?????????? Visual Studio ????**

?? **?????:** Visual Studio ?????????? restart ????????? environment variable ????

```
Visual Studio ? File ? Close
(Wait a few seconds)
Visual Studio ? Open solution again
```

---

### **Step 3: ???? Build Configuration**

??? Visual Studio Toolbar:

1. **Configuration**: `Release` (?????? Debug)
2. **Platform**: `x64` (?????? Win32)

```
[Release] ?    [x64] ?
   ?              ?
   |              ?? Must be x64
   ?? MUST be Release (not Debug!)
```

---

### **Step 4: Rebuild Solution**

```
Build ? Clean Solution
Build ? Rebuild Solution
```

**Wait for build to finish** (?????????? 1-2 ????)

---

### **Step 5: Verify Build Success**

```
? No errors in Output window
? Console Application built successfully
```

---

## **?? Test FPS and Performance**

### Run the application:
```
Debug ? Start Without Debugging (Ctrl+F5)
```

### Expected Results:
- ? Bounding box detection: **smooth, no stutter**
- ? FPS: **45-60** (depends on hardware/video)
- ? No lag when drawing parking slots

### ? If Still Slow:

1. **Double-check Configuration:**
   ```
   Project ? Properties
   Verify: Configuration = "Release", Platform = "x64"
   ```

2. **Verify Binary Size:**
   ```powershell
   # Release build should be ~10-20 MB
   # Debug build would be ~40-50 MB
   Get-Item "ConsoleApplication3\x64\Release\*.exe" | % { $_.Length / 1MB }
   ```

3. **Check Task Manager:**
   - Close other programs
   - Verify CPU/GPU not maxed out by other processes

---

## ?? **Checklist ??????????**

- [ ] Run `setup_opencv.bat`
- [ ] Restart Visual Studio
- [ ] Set Configuration = Release, Platform = x64
- [ ] Clean and Rebuild Solution
- [ ] Test FPS is smooth (45-60 FPS)
- [ ] No compilation errors

---

## ?? **Troubleshooting**

### ? "opencv_world4120.lib not found"
```
1. Run setup_opencv.bat again
2. Restart Visual Studio
3. Verify path in OPENCV_DIR:
   echo %OPENCV_DIR% (in Command Prompt)
```

### ? "Still using Debug configuration"
```
1. Visual Studio ? Build ? Clean Solution
2. Set Configuration dropdown to "Release"
3. Build ? Rebuild Solution
```

### ? "FPS still low (15-20 instead of 45+)"
```
1. Verify Release build:
   Project ? Properties
   C/C++ ? Optimization ? Should be "Maximize Speed (/O2)"

2. Check binary size:
   If Release .exe is >40MB, something's wrong
   Should be ~10-15MB

3. Clean everything:
   Delete x64\Release\ folder
   Rebuild Solution
```

---

## ?? **Need Help?**

If you're still having issues, check:
1. **OpenCV path** - Make sure it's correct
2. **Visual Studio restart** - Must restart after OPENCV_DIR setup
3. **Release build** - Must be Release|x64, not Debug|x64
4. **Rebuild** - Not just Build, but Rebuild Solution

---

**Expected Outcome:**
- ? Same FPS as original developer (45-60)
- ? Smooth bounding box animation
- ? No lag when drawing parking slots

Good luck! ??
