import cv2
from ultralytics import YOLO
from datetime import datetime
import os

# Inisialisasi model YOLO
model = YOLO('../models/tune_yolov8m_120-epochs/runs/detect/train/weights/best.pt')

# IP Kamera dari HP (IP Webcam)
ip_camera_url = 'http://10.204.1.126:8080/video'

cap = cv2.VideoCapture(ip_camera_url)

if not cap.isOpened():
    print("Gagal membuka IP camera stream")
    exit()

# Buat folder output otomatis
save_dir = 'runs/detect/vid'
os.makedirs(save_dir, exist_ok=True)

# Buat nama file otomatis berdasarkan waktu
timestamp = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
output_path = os.path.join(save_dir, f"{timestamp}.avi")

# Ambil resolusi dari stream
width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
fps = 20.0  # bisa kamu sesuaikan

# Setup penyimpanan video
fourcc = cv2.VideoWriter_fourcc(*'XVID')
out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

print(f"🔴 Menyimpan ke: {output_path}")

while True:
    ret, frame = cap.read()
    if not ret:
        print("Gagal membaca frame")
        break

    results = model.predict(source=frame, conf=0.25, verbose=False)
    annotated_frame = results[0].plot()

    # Tampilkan ke layar
    cv2.imshow("YOLOv8 - IP Cam", annotated_frame)

    # Simpan frame ke video
    out.write(annotated_frame)

    # Tekan 'q' untuk keluar
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Bersihkan
cap.release()
out.release()
cv2.destroyAllWindows()
