"""
ML service — placeholder/mock for future ML model integration.
Returns realistic mock responses matching the expected API contracts.
"""

import random


def analyze_xray(age: int, gender: str, symptoms: str, duration: str) -> dict:
    """
    Mock X-ray analysis endpoint.
    In production, this would:
      1. Load the uploaded image
      2. Preprocess for the model
      3. Run inference (e.g., TensorFlow/PyTorch TB detection model)
      4. Generate Grad-CAM heatmap
      5. Return structured prediction

    Args:
        age: Patient age
        gender: Patient gender
        symptoms: Comma-separated symptom list
        duration: Symptom duration

    Returns:
        Mocked analysis result matching ML output schema
    """
    # Simulate different outcomes based on symptoms
    symptom_list = [s.strip().lower() for s in symptoms.split(",") if s.strip()]

    # Higher risk if more severe symptoms are present
    severe_symptoms = {"chest pain", "shortness of breath", "weight loss", "night sweats"}
    severity_count = len(set(symptom_list) & severe_symptoms)

    if severity_count >= 2:
        prediction = "TB_DETECTED"
        confidence = round(random.uniform(0.78, 0.95), 2)
        risk_level = "HIGH"
        recommendation = (
            "Possible signs of tuberculosis detected. "
            "Please consult a pulmonologist immediately for further evaluation "
            "including sputum test and CT scan."
        )
    elif severity_count == 1 or len(symptom_list) >= 3:
        prediction = "PNEUMONIA_DETECTED"
        confidence = round(random.uniform(0.60, 0.82), 2)
        risk_level = "MEDIUM"
        recommendation = (
            "Signs consistent with pneumonia detected. "
            "Recommend chest CT and blood work. "
            "Visit a local health center within 24 hours."
        )
    else:
        prediction = "NORMAL"
        confidence = round(random.uniform(0.85, 0.97), 2)
        risk_level = "LOW"
        recommendation = (
            "No significant abnormalities detected. "
            "Continue monitoring symptoms and maintain hydration. "
            "Re-evaluate if symptoms persist beyond a week."
        )

    return {
        "prediction": prediction,
        "confidence": confidence,
        "risk_level": risk_level,
        "heatmap_url": "/mock/heatmap.png",
        "recommendation": recommendation,
    }


def process_vitals(
    red_signal: list[float],
    blue_signal: list[float],
    duration: float,
    user_id: str,
) -> dict:
    """
    Mock vitals processing endpoint.
    In production, this would:
      1. Apply bandpass filtering to the signal
      2. Perform FFT-based peak detection
      3. Compute heart rate from dominant frequency
      4. Estimate SpO2 from red/IR ratio using Beer-Lambert law

    Args:
        red_signal: Red channel intensity values
        blue_signal: Blue channel intensity values (proxy for IR)
        duration: Measurement duration in seconds
        user_id: Patient identifier

    Returns:
        Mocked vitals result matching expected schema
    """
    # Generate realistic-looking results
    heart_rate = random.randint(62, 98)
    spo2_estimate = random.randint(94, 99)

    # Confidence based on signal quality (length as proxy)
    signal_quality = min(1.0, len(red_signal) / 100.0) if red_signal else 0.3
    confidence = round(0.4 + signal_quality * 0.5, 2)

    return {
        "heart_rate": heart_rate,
        "spo2_estimate": spo2_estimate,
        "confidence": confidence,
    }
