import cv2
from ultralytics import YOLO

# Load model
model = YOLO('../models/tune_yolov8m_120-epochs/runs/detect/train/weights/best.pt')
# model = YOLO('../models/yolov8n_40_epochs/best.pt')

# webcam
cap = cv2.VideoCapture(0)

# Konfigurasi penyimpanan video
fourcc = cv2.VideoWriter_fourcc(*'XVID')  # atau 'MJPG' / 'mp4v'
out = cv2.VideoWriter('./runs/detect/vid/dawg.avi', fourcc, 20.0, (640, 480))  

if not cap.isOpened():
    print("Gagal membuka webcam")
    exit()

while True:
    ret, frame = cap.read()
    if not ret:
        break

    results = model.predict(source=frame, conf=0.25, verbose=False)
    annotated_frame = results[0].plot()

    # Simpan ke file
    out.write(annotated_frame)

    cv2.imshow('YOLOv8 Real-Time Detection', annotated_frame)

    # Tekan 'q' untuk keluar
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
out.release()
cv2.destroyAllWindows()