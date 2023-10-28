from flask import Flask, request, jsonify
from flask_cors import CORS
import os

# Initialize the Flask application
app = Flask(__name__)
CORS(app)

from groundingdino.util.inference import load_model, load_image, predict, annotate
import supervision as sv

CONFIG_PATH = "groundingdino/config/GroundingDINO_SwinT_OGC.py"
WEIGHTS_NAME = "groundingdino_swint_ogc.pth"
WEIGHTS_PATH = "weights/" + WEIGHTS_NAME
model = load_model(CONFIG_PATH, WEIGHTS_PATH)

@app.route('/predict', methods=['POST'])
def predict_api():
    try:
        # Get the image and the text prompt from the request
        image_file = request.files['image']
        text_prompt = request.form['prompt']

        # Convert the image to the format expected by your model
        print('=== loading image ===')
        image_source, image = load_image(image_file)

        # Model prediction
        BOX_TRESHOLD = 0.35
        TEXT_TRESHOLD = 0.25
        print('=== prediciting ===')
        boxes, logits, phrases = predict(
            model=model,
            image=image,
            caption=text_prompt,
            box_threshold=BOX_TRESHOLD,
            text_threshold=TEXT_TRESHOLD
        )

        # Prepare the response
        response = {
            'boxes': boxes.tolist(),
            'logits': logits.tolist(),
            'phrases': phrases
        }
        return jsonify(response)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)