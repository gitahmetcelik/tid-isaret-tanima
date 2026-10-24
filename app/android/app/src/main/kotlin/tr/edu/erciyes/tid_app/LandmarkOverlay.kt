package tr.edu.erciyes.tid_app

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.View
import kotlin.math.max

/** Normalize (0-1) nokta koordinatlarini PreviewView'in FILL_CENTER yerlesimine gore cizer. */
class LandmarkOverlay(context: Context) : View(context) {
    private val handPaint = Paint().apply { color = Color.GREEN; style = Paint.Style.FILL }
    private val posePaint = Paint().apply { color = Color.CYAN; style = Paint.Style.FILL }

    // [el][nokta] -> (x, y); null = el yok
    @Volatile private var hands: List<FloatArray?> = emptyList()
    @Volatile private var pose: FloatArray? = null
    @Volatile private var imgW = 1
    @Volatile private var imgH = 1
    /** On kamerada onizleme aynalanir; kaplama da x ekseninde aynalanmali. */
    @Volatile var mirror = false

    fun update(hands: List<FloatArray?>, pose: FloatArray?, imgW: Int, imgH: Int) {
        this.hands = hands; this.pose = pose; this.imgW = imgW; this.imgH = imgH
        postInvalidate()
    }

    override fun onDraw(canvas: Canvas) {
        val scale = max(width / imgW.toFloat(), height / imgH.toFloat())
        val dx = (width - imgW * scale) / 2f
        val dy = (height - imgH * scale) / 2f
        fun px(x: Float) = (if (mirror) 1f - x else x) * imgW * scale + dx
        fun py(y: Float) = y * imgH * scale + dy
        for (h in hands) {
            h ?: continue
            for (i in 0 until h.size / 2) canvas.drawCircle(px(h[2 * i]), py(h[2 * i + 1]), 6f, handPaint)
        }
        pose?.let { p -> for (i in 0 until p.size / 2) canvas.drawCircle(px(p[2 * i]), py(p[2 * i + 1]), 9f, posePaint) }
    }
}
