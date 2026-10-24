package tr.edu.erciyes.tid_app

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker
import com.google.mediapipe.tasks.vision.poselandmarker.PoseLandmarker

/** Egitimle ayni modeller (hand_landmarker, pose_landmarker_lite) ve ayni VIDEO modu. */
class LandmarkPipeline(context: Context) {
    class Frame(
        val hands: List<FloatArray?>,   // [slot 0 = Left, slot 1 = Right] -> x0,y0,x1,y1...
        val handLabels: List<String>,
        val pose: FloatArray?,          // 7 nokta: burun, omuzlar, dirsekler, bilekler
        val width: Int, val height: Int,
        val inferMs: Long,
    )

    private val hand: HandLandmarker = HandLandmarker.createFromOptions(
        context,
        HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(BaseOptions.builder().setModelAssetPath("hand_landmarker.task").build())
            .setRunningMode(RunningMode.VIDEO)
            .setNumHands(2)
            .build()
    )
    private val pose: PoseLandmarker = PoseLandmarker.createFromOptions(
        context,
        PoseLandmarker.PoseLandmarkerOptions.builder()
            .setBaseOptions(BaseOptions.builder().setModelAssetPath("pose_landmarker_lite.task").build())
            .setRunningMode(RunningMode.VIDEO)
            .build()
    )

    private val poseIdx = intArrayOf(0, 11, 12, 13, 14, 15, 16)
    private var lastTs = -1L

    fun process(image: ImageProxy): Frame {
        val t0 = System.nanoTime()
        val bmp = Bitmap.createBitmap(image.width, image.height, Bitmap.Config.ARGB_8888)
        image.planes[0].buffer.rewind()
        bmp.copyPixelsFromBuffer(image.planes[0].buffer)
        val rot = image.imageInfo.rotationDegrees
        val upright = if (rot == 0) bmp else
            Bitmap.createBitmap(bmp, 0, 0, bmp.width, bmp.height, Matrix().apply { postRotate(rot.toFloat()) }, true)
        val mpImage = BitmapImageBuilder(upright).build()

        var ts = image.imageInfo.timestamp / 1_000_000L
        if (ts <= lastTs) ts = lastTs + 1
        lastTs = ts

        val handRes = hand.detectForVideo(mpImage, ts)
        val slots = arrayOfNulls<FloatArray>(2)
        for (i in handRes.landmarks().indices) {
            val label = handRes.handednesses()[i][0].categoryName()
            val slot = if (label == "Left") 0 else 1
            slots[slot] = FloatArray(42).also { a ->
                handRes.landmarks()[i].forEachIndexed { j, p -> a[2 * j] = p.x(); a[2 * j + 1] = p.y() }
            }
        }
        val poseRes = pose.detectForVideo(mpImage, ts)
        val poseArr = poseRes.landmarks().firstOrNull()?.let { lms ->
            FloatArray(14).also { a -> poseIdx.forEachIndexed { k, j -> a[2 * k] = lms[j].x(); a[2 * k + 1] = lms[j].y() } }
        }
        val ms = (System.nanoTime() - t0) / 1_000_000
        return Frame(slots.toList(), listOf("Left", "Right"), poseArr, upright.width, upright.height, ms)
    }

    fun close() { hand.close(); pose.close() }
}
