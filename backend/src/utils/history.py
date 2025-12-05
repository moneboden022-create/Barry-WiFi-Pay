from sqlalchemy.orm import Session
from datetime import datetime
from models import ConnectionHistory

def create_history(
    db: Session,
    user_id: int,
    device_id: int = None,
    ip: str = None,
    user_agent: str = None,
    voucher: str = None,
    note: str = None,
    success: bool = True
):
    record = ConnectionHistory(
        user_id=user_id,
        device_id=device_id,
        ip=ip,
        user_agent=user_agent,
        voucher_code=voucher,
        start_at=datetime.utcnow(),
        success=success,
        note=note
    )

    db.add(record)
    db.commit()
    db.refresh(record)
    return record
