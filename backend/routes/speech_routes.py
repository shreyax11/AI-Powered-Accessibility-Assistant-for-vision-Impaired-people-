import os
import tempfile

from flask import Blueprint, request, jsonify
from services.speech_service import transcribe_audio


speech_routes = Blueprint("speech_routes", __name__)


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

    temp_path = None

    try:
        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".webm"
        ) as temp_file:

            audio_file.save(temp_file.name)
            temp_path = temp_file.name

        result = transcribe_audio(temp_path)

        return jsonify({
            "success": True,
            "text": result["text"],
            "language": result["language"]
        })

    except Exception as e:

        return jsonify({
            "success": False,
            "message": "Speech transcription failed",
            "error": str(e)
        }), 500

    finally:

        if temp_path and os.path.exists(temp_path):
            os.remove(temp_path)