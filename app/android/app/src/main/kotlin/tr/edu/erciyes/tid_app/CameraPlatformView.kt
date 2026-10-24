package tr.edu.erciyes.tid_app

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.concurrent.Executors

class CameraViewFactory(
    private val owner: LifecycleOwner,
    private val events: () -> EventChannel.EventSink?,
    private val onCreated: (CameraPlatformView?) -> Unit,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        CameraPlatformView(context, owner, events, onCreated).also { onCreated(it) }
}

/** CameraX onizleme + MediaPipe cikarimi + nokta kaplamasi. Kare akisi Dart'a gitmez, yalnizca ozet (FPS, el sayisi) gider. */
class CameraPlatformView(
    private val context: Context,
    private val owner: LifecycleOwner,
    private val events: () -> EventChannel.EventSink?,
    private val onDisposed: (CameraPlatformView?) -> Unit,
) : PlatformView {
    private val root = FrameLayout(context)
    private val preview = PreviewView(context).apply { implementationMode = PreviewView.ImplementationMode.COMPATIBLE }
    private val overlay = LandmarkOverlay(context)
    private val executor = Executors.newSingleThreadExecutor()
    private val pipeline = LandmarkPipeline(context)
    private var provider: ProcessCameraProvider? = null
    private var front = false
    private var prev: Preview? = null
    private var analysis: ImageAnalysis? = null
    private var lastReport = System.nanoTime()
    private var frames = 0
    private var inferSum = 0L

    init {
        root.addView(preview, FrameLayout.LayoutParams(-1, -1))
        root.addView(overlay, FrameLayout.LayoutParams(-1, -1))
        val future = ProcessCameraProvider.getInstance(context)
        future.addListener({
            provider = future.get()
            prev = Preview.Builder().build().also { it.setSurfaceProvider(preview.surfaceProvider) }
            analysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                .build()
            analysis!!.setAnalyzer(executor) { img ->
                try {
                    val f = pipeline.process(img)
                    overlay.update(f.hands, f.pose, f.width, f.height)
                    report(f)
                } finally {
                    img.close()
                }
            }
            bind()
        }, ContextCompat.getMainExecutor(context))
    }

    /** Arka/on kamera degistir. Analiz goruntusu aynalanmaz (AUTSL videolari gibi); yalnizca kaplama onizlemeyle hizalanir. */
    fun setFront(f: Boolean) {
        front = f
        ContextCompat.getMainExecutor(context).execute { bind() }
    }

    private fun bind() {
        val p = provider ?: return
        overlay.mirror = front
        p.unbindAll()
        val sel = if (front) CameraSelector.DEFAULT_FRONT_CAMERA else CameraSelector.DEFAULT_BACK_CAMERA
        p.bindToLifecycle(owner, sel, prev!!, analysis!!)
    }

    private fun report(f: LandmarkPipeline.Frame) {
        frames++; inferSum += f.inferMs
        val now = System.nanoTime()
        if (now - lastReport >= 500_000_000L) {
            val fps = frames * 1e9 / (now - lastReport)
            val msg = mapOf(
                "fps" to fps, "inferMs" to inferSum.toDouble() / frames,
                "hands" to f.hands.count { it != null }, "pose" to (f.pose != null),
                "w" to f.width, "h" to f.height, "front" to front,
            )
            ContextCompat.getMainExecutor(context).execute { events()?.success(msg) }
            frames = 0; inferSum = 0; lastReport = now
        }
    }

    override fun getView(): View = root

    override fun dispose() {
        provider?.unbindAll()
        executor.shutdown()
        pipeline.close()
        onDisposed(null)
    }
}
