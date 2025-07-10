from flask import Flask, Response, request, jsonify, stream_with_context
from ultralytics import YOLO
import os
import shutil
import uuid
from openai import OpenAI
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024 

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'static', 'uploads')
RESULT_FOLDER = os.path.join(BASE_DIR, 'static', 'results')
TEMP_RUN_FOLDER = os.path.join(BASE_DIR, 'runs', 'detect', 'temp')

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(RESULT_FOLDER, exist_ok=True)
os.makedirs(TEMP_RUN_FOLDER, exist_ok=True)

api_key = os.getenv('OPENAI_API_KEY')
client = OpenAI(api_key=api_key)

model = YOLO(os.path.join(BASE_DIR, 'best_model2.pt'))

def clear_temp_folder(folder):
    if os.path.exists(folder):
        shutil.rmtree(folder)
    os.makedirs(folder)

@app.route('/')
def index():
    return "✅ Eye Disease Detection Backend is Running"

@app.route('/predict', methods=['POST'])
def predict():

    if 'image' not in request.files:
        return jsonify({'error': 'No image uploaded'}), 400

    image = request.files['image']
    if image.filename == '':
        return jsonify({'error': 'No image selected'}), 400

    image.seek(0, os.SEEK_END)
    file_size = image.tell()
    image.seek(0)

    if file_size == 0:
        return jsonify({'error': 'Uploaded image is empty'}), 400
    
    unique_filename = f"{uuid.uuid4().hex}.jpg"
    upload_path = os.path.join(UPLOAD_FOLDER, unique_filename)

    # print(f"🧾 Incoming filename: {original_filename}")
    print(f"📂 Saving to path: {upload_path}")

    os.makedirs(UPLOAD_FOLDER, exist_ok=True)
    print("Folder TERSEDIA: ",os.path.exists(UPLOAD_FOLDER))
    
    print(f"🔍 Path length: {len(upload_path)}")

    try:
        image.save(upload_path)
        print("✅ File berhasil disimpan.")
    except Exception as e:
        print("❌ Gagal menyimpan file:", str(e))
        return jsonify({'error': 'Failed to save image', 'detail': str(e)}), 500

    clear_temp_folder(TEMP_RUN_FOLDER)

    results = model.predict(
        upload_path,
        save=True,
        project=os.path.join(BASE_DIR, 'runs', 'detect'),
        name='temp',
        exist_ok=True
    )

    predicted_path = os.path.join(TEMP_RUN_FOLDER, unique_filename)
    final_result_path = os.path.join(RESULT_FOLDER, unique_filename)

    try:
        shutil.copy(predicted_path, final_result_path)
    except Exception as e:
        return jsonify({'error': f'Prediction result not found: {str(e)}'}), 500

    detections = []
    boxes = results[0].boxes
    class_names = results[0].names

    for box in boxes:
        class_id = int(box.cls[0])
        confidence = float(box.conf[0])
        detections.append({
            "class": class_names[class_id],
            "confidence": confidence
        })

    image_url = f"http://{request.host}/static/results/{unique_filename}"

    return jsonify({
        "detections": detections,
        "image_path": image_url
    })

@app.route('/explain', methods=['POST'])
def explain():
    data = request.json
    result_class = data.get('resultClass', '')
    confidence = data.get('confidence', 0.0)

    prompt = f"""
I have just received the result of an eye disease detection processed using a YOLOv8-based screening model from my application. The detected eye condition is: {result_class}, with a model confidence score of {confidence:.2f}.

Please explain the result to the user in **two paragraphs**:

- In the first paragraph, describe the detection result and provide a technical interpretation of the model’s confidence score using evaluation metrics:
  - If confidence < 0.4, classify it as a "Low Confidence" prediction. Explain that the model is not confident in this result. At this level, recall tends to be high, but precision is low. Discuss the potential risk of false positives or false negatives for the predicted class. For example, if the result is "Conjunctivitis", explain whether the model is more likely mistaking a healthy eye as conjunctivitis (false positive), or failing to detect a real conjunctivitis case (false negative), based on your evaluation findings.
  - If confidence is between 0.4 and 0.7, treat it as a "Correct Prediction". This means the model’s confidence lies in the optimal range where precision and recall are balanced, supported by the F1-Score evaluation.
  - If confidence > 0.7, classify it as a "High Confidence" prediction. Mention that the model is very confident in this prediction. At this level, precision is high, so the chance of false positives is low, although it might still miss subtle or borderline cases (lower recall).

- In the second paragraph, provide a clear explanation of the detected condition ({result_class}) using **simple, user-friendly language**. Avoid technical or medical jargon. Assume the reader has no background in healthcare. Explain what the condition is, common symptoms, how it may affect vision, and general advice on what to do next (e.g., rest, eye hygiene, or consulting a doctor if symptoms persist).

Important: Return the output in **plain English**, using clean formatting. Do **not use Markdown or asterisks** (e.g., no `**bold**` syntax), but emphasize important terms using natural language.

"""

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {"role": "system", "content": "You are a helpful and friendly medical assistant. Answer only about eye diseases."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=300
        )
        explanation = response.choices[0].message.content
        return jsonify({"explanation": explanation})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/chat', methods=['POST'])
def chat_with_llm():
    data = request.json
    question = data.get('question', '')
    result_class = data.get('resultClass', 'Unknown')
    confidence = data.get('confidence', 0.0)

    if not question:
        return jsonify({"error": "No question provided"}), 400

    system_prompt = f"""
You are a helpful and empathetic assistant for an AI-powered eye disease screening app.
Result: {result_class}
Confidence: {confidence:.2f}
"""

    def generate():
        try:
            response = client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": question}
                ],
                stream=True,
                temperature=0.6,
                max_tokens=200,
            )
            for chunk in response:
                if chunk.choices and chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
        except Exception as e:
            print("❌ Error during streaming:", str(e))
            yield "\n[⚠️ Error occurred while processing response]"

    return Response(stream_with_context(generate()), mimetype='text/plain')

if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=5000)
