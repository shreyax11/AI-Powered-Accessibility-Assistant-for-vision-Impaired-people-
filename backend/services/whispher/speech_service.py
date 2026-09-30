from faster_whisper import WhisperModel

# Load Whisper model only when needed
_model = None


def get_whisper_model():
    global _model

    if _model is None:
        print("Loading Whisper model...")

        _model = WhisperModel(
            "base",
            device="cpu",
            compute_type="int8"
        )

        print("Whisper model loaded successfully.")

    return _model


def transcribe_audio(audio_path):
    model = get_whisper_model()

    segments, info = model.transcribe(
        audio_path,
        beam_size=5
    )

    text = " ".join(
        segment.text.strip()
        for segment in segments
    ).strip()

    return {
        "text": text,
        "language": info.language
    }
