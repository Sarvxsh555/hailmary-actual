"""
Record service — CRUD operations for health records.
"""

import uuid
from datetime import datetime, timezone
from utils.json_store import read_json, append_json, filter_by_field


def get_records(user_id: str | None = None) -> list:
    """
    Retrieve all health records, optionally filtered by user ID.

    Args:
        user_id: Optional user ID to filter by

    Returns:
        List of health record dicts
    """
    if user_id:
        return filter_by_field("records.json", "user_id", user_id)
    return read_json("records.json")


def create_record(
    user_id: str,
    record_type: str,
    result_summary: str,
    risk_level: str = "LOW",
    details: dict | None = None,
) -> dict:
    """
    Create and store a new health record.

    Args:
        user_id: Patient identifier
        record_type: Type of record ('xray', 'vitals', 'emergency')
        result_summary: Short human-readable summary
        risk_level: Risk categorization (LOW/MEDIUM/HIGH)
        details: Full detail payload

    Returns:
        The created record
    """
    record_id = f"REC-{uuid.uuid4().hex[:8].upper()}"
    now = datetime.now(timezone.utc).isoformat()

    record = {
        "id": record_id,
        "user_id": user_id,
        "type": record_type,
        "date": now,
        "result_summary": result_summary,
        "risk_level": risk_level,
        "details": details or {},
    }

    append_json("records.json", record)
    return record


def create_record_from_analysis(user_id: str, analysis_result: dict) -> dict:
    """
    Create a record from an X-ray analysis result.
    """
    prediction = analysis_result.get("prediction", "UNKNOWN")
    confidence = analysis_result.get("confidence", 0)
    risk = analysis_result.get("risk_level", "LOW")

    summary = f"{prediction.replace('_', ' ').title()} — Confidence: {int(confidence * 100)}%"

    return create_record(
        user_id=user_id,
        record_type="xray",
        result_summary=summary,
        risk_level=risk,
        details=analysis_result,
    )


def create_record_from_vitals(user_id: str, vitals_result: dict) -> dict:
    """
    Create a record from a vitals measurement result.
    """
    hr = vitals_result.get("heart_rate", 0)
    spo2 = vitals_result.get("spo2_estimate", 0)

    summary = f"HR: {hr} BPM • SpO₂: {spo2}%"

    # Determine risk based on values
    risk = "LOW"
    if hr < 50 or hr > 120 or spo2 < 90:
        risk = "HIGH"
    elif hr < 60 or hr > 100 or spo2 < 95:
        risk = "MEDIUM"

    return create_record(
        user_id=user_id,
        record_type="vitals",
        result_summary=summary,
        risk_level=risk,
        details=vitals_result,
    )
