"""Test videosunu tam ekran oynatir (telefon-ekran deneyi icin). Cikis: Esc."""
import sys
import cv2

cap = cv2.VideoCapture(sys.argv[1])
cv2.namedWindow("demo", cv2.WINDOW_NORMAL)
cv2.setWindowProperty("demo", cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)
while True:
    ok, f = cap.read()
    if not ok:
        break
    cv2.imshow("demo", f)
    if cv2.waitKey(33) == 27:
        break
cv2.destroyAllWindows()
