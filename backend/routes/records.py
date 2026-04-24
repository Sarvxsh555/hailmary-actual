"""
Records routes — CRUD for health records (X-ray, vitals, emergency).
"""

from fastapi import APIRouter
from pydantic import BaseModel
from services.record_service import get_records, create_record

router = APIRouter(prefix="/records", tags=["Records"])


class RecordCreateRequest(BaseModel):
    user_id: str = "patient_001"
    type: str  # 'xray', 'vitals', 'emergency'
    result_summary: str = ""
    risk_level: str = "LOW"
    details: dict = {}


@router.get("")
async def list_records(user_id: str | None = None):
    """
    Retrieve all health records, optionally filtered by user_id.
    Returns records sorted by date (newest first).
    """
    records = get_records(user_id=user_id)
    # Sort by date descending
    records.sort(key=lambda r: r.get("date", ""), reverse=True)
    return records


@router.post("")
async def add_record(req: RecordCreateRequest):
    """
    Create a new health record.
    """
    record = create_record(
        user_id=req.user_id,
        record_type=req.type,
        result_summary=req.result_summary,
        risk_level=req.risk_level,
        details=req.details,
    )
    return record
