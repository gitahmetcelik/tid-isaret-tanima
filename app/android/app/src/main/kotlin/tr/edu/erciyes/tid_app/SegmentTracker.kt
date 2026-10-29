package tr.edu.erciyes.tid_app

import android.util.Log
import kotlin.math.hypot

/**
 * Surekli tanima icin isaret segmentleme.
 *
 * Etkinlik: en az bir el, omuz ortasinin bir omuz genisligi altindan daha yukarida (isaret alani).
 * Etkinlik 2 ardisik karede baslarsa segment acilir (onceki 8 kare onden eklenir, egitim verisindeki
 * "hazir bekleme" karelerini taklit etmek icin); 600 ms etkinlik olmazsa veya 6 saniye dolarsa kapanir.
 * 12 kareden kisa segmentler atilir.
 */
class SegmentTracker(private val onSegment: (List<SignClassifier.Sample>) -> Unit) {
    var inSegment = false
        private set
    private val pre = ArrayDeque<SignClassifier.Sample>()
    private val seg = ArrayList<SignClassifier.Sample>()
    private var activeRun = 0
    private var lastActiveNs = 0L
    private var segStartNs = 0L

    fun reset() { inSegment = false; pre.clear(); seg.clear(); activeRun = 0 }

    fun add(s: SignClassifier.Sample, nowNs: Long) {
        val active = isActive(s)
        if (!inSegment) {
            pre.addLast(s)
            if (pre.size > PRE_ROLL) pre.removeFirst()
            activeRun = if (active) activeRun + 1 else 0
            if (activeRun >= START_RUN) {
                inSegment = true
                seg.clear(); seg.addAll(pre)
                lastActiveNs = nowNs; segStartNs = nowNs
            }
        } else {
            seg.add(s)
            if (active) lastActiveNs = nowNs
            val idleMs = (nowNs - lastActiveNs) / 1_000_000
            val lenS = (nowNs - segStartNs) / 1e9
            if (idleMs >= END_GAP_MS || lenS >= MAX_SECONDS) finish(if (idleMs >= END_GAP_MS) "bosluk" else "max-sure")
        }
    }

    private fun finish(reason: String) {
        val done = ArrayList(seg)
        Log.i("TIDSEG", "segment kapandi: kare=${done.size} sebep=$reason ${if (done.size >= MIN_FRAMES) "-> siniflandiriliyor" else "-> cok kisa, atildi"}")
        reset()
        if (done.size >= MIN_FRAMES) onSegment(done)
    }

    private fun isActive(s: SignClassifier.Sample): Boolean {
        val p = s.pose ?: return s.hands.any { it != null }
        val cy = (p[3] + p[5]) / 2 * s.h
        val sw = hypot((p[2] - p[4]) * s.w, (p[3] - p[5]) * s.h)
        if (sw < 1f) return false
        return s.hands.any { h -> h != null && h[1] * s.h < cy + sw }  // landmark 0 = bilek
    }

    companion object {
        const val PRE_ROLL = 8
        const val START_RUN = 2
        const val END_GAP_MS = 600L
        const val MAX_SECONDS = 6.0
        const val MIN_FRAMES = 12
    }
}
