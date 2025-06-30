package net.empathetech.liminal

import android.app.WallpaperManager
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.provider.Settings

import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import java.io.ByteArrayOutputStream

class MainActivity : FlutterFragmentActivity() {
  private val CHANNEL = "net.empathetech.liminal/query"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getApps" -> {
          val apps = getInstalledApps()
          result.success(apps)
        }
        "launchApp" -> {
          try {
            val packageName = call.argument<String>("packageName")
            if (packageName != null) {
              launchApp(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Could not launch app", e.message)
          }
        }
        "getWallpaper" -> {
          try {
            val wallpaper = getSystemWallpaper()
            if (wallpaper != null) {
              result.success(wallpaper)
            } else {
              result.failed("WALLPAPER_FAILURE", "null wallpaper", null)
            }
          } catch (e: Exception) {
            result.error("WALLPAPER_ERROR", "Could not retrieve wallpaper", e.message)
          }
        }
        "openSettings" -> {
          try {
            val packageName = call.argument<String>("packageName")
            if (packageName != null) {
              openSettings(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("LAUNCH_ERROR", "Could not open settings", e.message)
          }
        }
        "deleteApp" -> {
          try {
            val packageName = call.argument<String>("packageName")
            if (packageName != null) {
              deleteApp(packageName)
              result.success(true)
            } else {
              result.error("INVALID_PACKAGE", "null package name", null)
            }
          } catch (e: Exception) {
            result.error("DELETE_ERROR", "Could not uninstall app", e.message)
          }
        }
        else -> result.notImplemented() 
      }
    }
  }

  private fun getInstalledApps(): List<Map<String, Any?>> {
    val pm: PackageManager = packageManager

    val intent = Intent(Intent.ACTION_MAIN, null)
    intent.addCategory(Intent.CATEGORY_LAUNCHER)

    val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      pm.queryIntentActivities(intent, PackageManager.ResolveInfoFlags.of(0L))
    } else {
      @Suppress("DEPRECATION")
      pm.queryIntentActivities(intent, 0)
    }

    val apps = mutableListOf<Map<String, Any?>>()
    for (info in appInfo) {
      val app = mutableMapOf<String, Any?>()

      app["label"] = info.loadLabel(pm).toString()
      app["package"] = info.activityInfo.packageName
      app["icon"] = drawableToByteArray(info.loadIcon(pm))
      
      val isSystemApp = (info.activityInfo.applicationInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
      app["removable"] = !isSystemApp

      apps.add(app)
    }
    return apps
  }

  private fun drawableToByteArray(drawable: Drawable?): ByteArray? {
    if (drawable == null) return null
    
    if (drawable is BitmapDrawable) {
      val bitmap = drawable.bitmap
      val stream = ByteArrayOutputStream()
      bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
      return stream.toByteArray()
    }

    val bitmap = Bitmap.createBitmap(
      drawable.intrinsicWidth,
      drawable.intrinsicHeight,
      Bitmap.Config.ARGB_8888
    )

    val canvas = Canvas(bitmap)
    drawable.setBounds(0, 0, canvas.width, canvas.height)
    drawable.draw(canvas)

    val stream = ByteArrayOutputStream()
    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
    return stream.toByteArray()
  }

  private fun getSystemWallpaper(): ByteArray? {
    val wallpaperManager = WallpaperManager.getInstance(applicationContext)
    return try {
      val wallpaperDrawable = wallpaperManager.drawable
      if (wallpaperDrawable is BitmapDrawable) {
        val bitmap = wallpaperDrawable.bitmap
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        stream.toByteArray()
      } else {
        null
      }
    } catch (e: Exception) {
      e.printStackTrace()
      null
    }
  }

  private fun launchApp(packageName: String) {
    val launchIntent: Intent? = packageManager.getLaunchIntentForPackage(packageName)
    if (launchIntent != null) startActivity(launchIntent)
  }

  private fun openSettings(packageName: String) {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
    intent.data = Uri.fromParts("package", packageName, null)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(intent)
  }

  private fun deleteApp(packageName: String) {
    val intent = Intent(Intent.ACTION_DELETE)
    intent.data = Uri.fromParts("package", packageName, null)
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    startActivity(intent)
  }
}