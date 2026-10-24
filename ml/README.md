# ml/: nokta çıkarımı ve model eğitimi

## Ortam (Python 3.12)

```bash
uv venv --python 3.12 ml/.venv
uv pip install --python ml/.venv/Scripts/python.exe -r ml/requirements.txt
```

## MediaPipe modelleri (resmi Google adresi, repoya girmez)

```bash
mkdir -p ml/models
curl -L -o ml/models/hand_landmarker.task https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task
curl -L -o ml/models/pose_landmarker_lite.task https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/latest/pose_landmarker_lite.task
```

## Nokta çıkarımı

Veri `data/archive (1)/` altında olmalıdır (Kaggle `sttaseen/autsl`, bkz. docs/data.md).

```bash
ml/.venv/Scripts/python.exe ml/extract_keypoints.py --split train --classes 30,175,65 --workers 4 --out data/keypoints_10
```
