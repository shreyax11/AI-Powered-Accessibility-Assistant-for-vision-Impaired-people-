import os
import tempfile

from flask import Blueprint, request, jsonify
from services.speech_service import transcribe_audio
from faster_whisper import WhisperModel


speech_routes = Blueprint("speech_routes", __name__)

# Initialize faster-whisper once when the blueprint/server loads
MODEL_SIZE = "base"
print(f"Loading faster-whisper model ({MODEL_SIZE})...")
whisper_model = WhisperModel(MODEL_SIZE, device="cpu", compute_type="int8")
print("Whisper model loaded successfully!")

@speech_routes.route("/api/speech-to-text", methods=["POST"])
def speech_to_text():

    if "audio" not in request.files:
        return jsonify({
            "success": False,
            "message": "No audio file received"
        }), 400

    audio_file = request.files["audio"]

    if audio_file.filename == "":
        return jsonify({
            "success": False,
            "message": "Empty audio file"
        }), 400

    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".wav")

    try:
        audio_file.save(temp_file.name)
        temp_file.close()

        # Perform transcription
        segments, info = whisper_model.transcribe(temp_file.name, beam_size=5)
        transcribed_text = " ".join([segment.text for segment in segments]).strip()

        print(f"Transcribed Text: {transcribed_text}")

        return jsonify({
            "success": True,
            "text": transcribed_text,
            "language": info.language
        }), 200

    except Exception as e:

        return jsonify({
            "success": False,
            "message": "Speech transcription failed",
            "error": str(e)
        }), 500

    finally:

        if temp_file and os.path.exists(temp_file.name):
            os.remove(temp_file.name)