"""
Emergency service — handles emergency event logging and mock notifications.
"""

import uuid
from datetime import datetime, timezone
from utils.json_store import append_json, read_json


def trigger_emergency(user_id: str, location: str, description: str) -> dict:
    """
    Log a new emergency event and simulate alerting.

    Args:
        user_id: ID of the patient triggering the emergency
        location: Location description
        description: Additional context

    Returns:
        The created emergency event record
    """
    event_id = f"EMG-{uuid.uuid4().hex[:8].upper()}"
    timestamp = datetime.now(timezone.utc).isoformat()

    event = {
        "id": event_id,
        "user_id": user_id,
        "location": location,
        "description": description,
        "timestamp": timestamp,
        "status": "TRIGGERED",
    }

    # Persist to JSON
    append_json("emergencies.json", event)

    # Simulate notification log
    _mock_notify(event)

    return event


def get_emergencies(user_id: str | None = None) -> list:
    """
    Retrieve emergency events, optionally filtered by user.
    """
    data = read_json("emergencies.json")
    if user_id:
        return [e for e in data if e.get("user_id") == user_id]
    return data


def _mock_notify(event: dict) -> None:
    """
    Simulate sending notifications for an emergency.
    In production, this would integrate with SMS/push/email services.
    """
    notifications = [
        f"[NOTIFY] Emergency Health Center alerted for event {event['id']}",
        f"[NOTIFY] Emergency contacts notified — Location: {event['location']}",
        f"[NOTIFY] Emergency contact SMS queued for user {event['user_id']}",
    ]

    # Log notifications (in production: send via actual channels)
    for notif in notifications:
        print(notif)

    # Also append to a notification log
    append_json("notifications.json", {
        "event_id": event["id"],
        "timestamp": event["timestamp"],
        "notifications": notifications,
        "status": "SENT",
    })
