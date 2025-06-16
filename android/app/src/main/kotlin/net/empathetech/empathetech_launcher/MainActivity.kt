package net.empathetech.liminal

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build

import androidx.annotation.NonNull

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
  private val CHANNEL = "net.empathetech.liminal/query"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getApps" -> {
          val apps = getInstalledApps()
          result.success(apps)
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
}