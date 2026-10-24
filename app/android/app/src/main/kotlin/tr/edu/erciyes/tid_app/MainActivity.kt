package tr.edu.erciyes.tid_app

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer
import java.nio.ByteOrder

class MainActivity : FlutterActivity() {
    private var sink: EventChannel.EventSink? = null
    private var pendingPermission: MethodChannel.Result? = null
    private var cameraView: CameraPlatformView? = null

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
            } else if (call.method == "setLens") {
                cameraView?.setFront(call.arguments as? Boolean ?: false)
                result.success(null)
            } else if (call.method == "setMode") {
                cameraView?.setMode(call.arguments as? Int ?: 1)
                result.success(null)
            } else if (call.method == "selftest") {
                runSelfTest(result)
            } else if (call.method == "record") {
                cameraView?.record(call.arguments as? Boolean ?: false, result) ?: result.success(null)
            } else result.notImplemented()
        }

        flutterEngine.platformViewsController.registry
            .registerViewFactory("tid/camera_view", CameraViewFactory(this, { sink }) { cameraView = it })
    }

    /** Kotlin on isleme + LiteRT'in Python ile ayni sonucu verdigini gomulu 200 test ornegiyle dogrular. */
    private fun runSelfTest(result: MethodChannel.Result) {
        Thread {
            val reply: Map<String, Any> = try {
                val clf = SignClassifier(this)
                val buf = ByteBuffer.wrap(assets.open("selftest.bin").readBytes()).order(ByteOrder.LITTLE_ENDIAN)
                var n = 0; var correct = 0; var agree = 0
                val t0 = System.nanoTime()
                while (buf.hasRemaining()) {
                    val t = buf.int; val label = buf.int; val pyPred = buf.int
                    val frames = ArrayList<SignClassifier.Sample>(t)
                    repeat(t) {
                        val hand = FloatArray(84) { buf.float }
                        val pose = FloatArray(14) { buf.float }
                        val hok = floatArrayOf(buf.float, buf.float)
                        val pok = buf.float > 0.5f
                        frames.add(SignClassifier.Sample(
                            Array(2) { s -> if (hok[s] > 0.5f) hand.copyOfRange(s * 42, s * 42 + 42) else null },
                            if (pok) pose else null, 512, 512))
                    }
                    val top = clf.classify(frames, 1)[0].index
                    n++; if (top == label) correct++; if (top == pyPred) agree++
                }
                clf.close()
                mapOf("n" to n, "accuracy" to correct.toDouble() / n, "agreePython" to agree.toDouble() / n,
                    "msPerSample" to (System.nanoTime() - t0) / 1_000_000.0 / n)
            } catch (e: Exception) { mapOf("error" to (e.message ?: e.toString())) }
            runOnUiThread { result.success(reply) }
        }.start()
    }

    override fun onRequestPermissionsResult(code: Int, permissions: Array<out String>, grants: IntArray) {
        super.onRequestPermissionsResult(code, permissions, grants)
        if (code == 42) {
            pendingPermission?.success(grants.isNotEmpty() && grants[0] == PackageManager.PERMISSION_GRANTED)
            pendingPermission = null
        }
    }
}
