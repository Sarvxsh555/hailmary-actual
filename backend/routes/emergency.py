"""
Emergency routes — handles emergency event triggering and retrieval.
"""

from fastapi import APIRouter
from pydantic import BaseModel
from services.emergency_service import trigger_emergency, get_emergencies

router = APIRouter(prefix="/emergency", tags=["Emergency"])


class EmergencyRequest(BaseModel):
    user_id: str
    location: str = "Unknown"
    description: str = ""
    timestamp: str | None = None


@router.post("")
async def create_emergency(req: EmergencyRequest):
    """
    Trigger an emergency event.
    Logs the event and simulates alerting emergency health services.
    """
    event = trigger_emergency(
        user_id=req.user_id,
        location=req.location,
        description=req.description,
    )
    return event


@router.get("")
async def list_emergencies(user_id: str | None = None):
    """
    Retrieve all emergency events, optionally filtered by user_id.
    """
    return get_emergencies(user_id=user_id)
