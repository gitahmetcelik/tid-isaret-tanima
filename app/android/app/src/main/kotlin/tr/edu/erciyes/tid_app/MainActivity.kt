package tr.edu.erciyes.tid_app

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sink: EventChannel.EventSink? = null
    private var pendingPermission: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        EventChannel(messenger, "tid/landmarks").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, events: EventChannel.EventSink?) { sink = events }
            override fun onCancel(args: Any?) { sink = null }
        })

        MethodChannel(messenger, "tid/control").setMethodCallHandler { call, result ->
            if (call.method == "ensureCamera") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                    result.success(true)
                } else {
                    pendingPermission = result
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), 42)
                }
            } else result.notImplemented()
        }

        flutterEngine.platformViewsController.registry
            .registerViewFactory("tid/camera_view", CameraViewFactory(this) { sink })
    }

    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, grants: IntArray) {
        super.onRequestPermissionsResult(code, permissions, grants)
        if (code == 42) {
            pendingPermission?.success(grants.isNotEmpty() && grants[0] == PackageManager.PERMISSION_GRANTED)
            pendingPermission = null
        }
    }
}
