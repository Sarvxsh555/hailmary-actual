"""
ML routes — placeholder endpoints for X-ray analysis and vitals processing.
These return mocked responses matching the expected ML output format.
"""

from fastapi import APIRouter, File, Form, UploadFile
from pydantic import BaseModel
from services.ml_service import analyze_xray, process_vitals
from services.record_service import create_record_from_analysis, create_record_from_vitals

router = APIRouter(prefix="/ml", tags=["ML / AI"])


# ─── X-Ray Analysis ────────────────────────────────────────────


@router.post("/analyze")
async def analyze_xray_endpoint(
    image: UploadFile = File(...),
    age: int = Form(0),
    gender: str = Form("Unknown"),
    symptoms: str = Form(""),
    duration: str = Form("Unknown"),
):
    """
    Analyze a chest X-ray image (mock).

    Accepts multipart form data with the X-ray image and patient metadata.
    Returns a structured prediction result.

    In production, this would:
    - Load and preprocess the image
    - Run inference through a trained TB/pneumonia detection model
    - Generate a Grad-CAM heatmap
    - Return prediction with confidence and recommendation
    """
    # Read file metadata (we don't process the image in mock)
    file_size = 0
    contents = await image.read()
    file_size = len(contents)

    print(f"[ML] Received X-ray: {image.filename}, size={file_size} bytes")
    print(f"[ML] Patient: age={age}, gender={gender}, symptoms={symptoms}, duration={duration}")

    # Get mock analysis result
    result = analyze_xray(
        age=age,
        gender=gender,
        symptoms=symptoms,
        duration=duration,
    )

    # Auto-save to records
    create_record_from_analysis(
        user_id="patient_001",  # In production: extract from auth token
        analysis_result=result,
    )

    return result


# ─── Vitals Processing ─────────────────────────────────────────


class VitalsRequest(BaseModel):
    red_signal: list[float] = []
    blue_signal: list[float] = []
    duration: float = 0.0
    user_id: str = "patient_001"


@router.post("/vitals")
async def process_vitals_endpoint(req: VitalsRequest):
    """
    Process vitals measurement data (mock).

    Accepts processed signal data from the mobile app's camera-based
    measurement and returns heart rate and SpO2 estimates.

    In production, this would:
    - Apply bandpass filtering (0.7-3.5 Hz for heart rate)
    - Perform FFT-based peak detection
    - Compute BPM from dominant frequency components
    - Estimate SpO2 using Beer-Lambert law with R/IR ratio
    """
    print(f"[ML] Vitals data received: {len(req.red_signal)} red samples, "
          f"{len(req.blue_signal)} blue samples, duration={req.duration}s")

    result = process_vitals(
        red_signal=req.red_signal,
        blue_signal=req.blue_signal,
        duration=req.duration,
        user_id=req.user_id,
    )

    # Auto-save to records
    create_record_from_vitals(
        user_id=req.user_id,
        vitals_result=result,
    )

    return result
