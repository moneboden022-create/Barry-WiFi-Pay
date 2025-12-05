# backend/src/routers/admin_stats.py
"""
📊 Statistiques Admin avancées pour BARRY WiFi
Graphiques journaliers, hebdomadaires, mensuels + heatmaps
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import func, extract
from datetime import datetime, timedelta
from typing import Optional, List

from ..db import get_db
from ..deps import admin_required
from ..models import (
    User, Payment, Subscription, WifiAccess, 
    ConnectionHistory, Device, Voucher, DailyStatistics
)

router = APIRouter(prefix="/admin/stats", tags=["Admin Statistics"])


# ============================================================
# 📊 STATS GÉNÉRALES (Dashboard principal)
# ============================================================
@router.get("/overview")
def get_overview_stats(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Statistiques générales pour le dashboard admin"""
    
    now = datetime.utcnow()
    today_start = datetime(now.year, now.month, now.day)
    week_start = today_start - timedelta(days=now.weekday())
    month_start = datetime(now.year, now.month, 1)
    
    return {
        "users": {
            "total": db.query(func.count(User.id)).scalar() or 0,
            "active": db.query(func.count(User.id)).filter(User.is_active == True).scalar() or 0,
            "today": db.query(func.count(User.id)).filter(User.created_at >= today_start).scalar() or 0,
            "this_week": db.query(func.count(User.id)).filter(User.created_at >= week_start).scalar() or 0,
            "this_month": db.query(func.count(User.id)).filter(User.created_at >= month_start).scalar() or 0,
            "business": db.query(func.count(User.id)).filter(User.isBusiness == True).scalar() or 0,
        },
        "subscriptions": {
            "active": db.query(func.count(Subscription.id)).filter(
                Subscription.is_active == True, 
                Subscription.end_at > now
            ).scalar() or 0,
            "expired": db.query(func.count(Subscription.id)).filter(Subscription.end_at <= now).scalar() or 0,
            "total": db.query(func.count(Subscription.id)).scalar() or 0,
        },
        "devices": {
            "total": db.query(func.count(Device.id)).scalar() or 0,
            "blocked": db.query(func.count(Device.id)).filter(Device.is_blocked == True).scalar() or 0,
            "active_today": db.query(func.count(Device.id)).filter(Device.last_seen >= today_start).scalar() or 0,
        },
        "connections": {
            "total": db.query(func.count(ConnectionHistory.id)).scalar() or 0,
            "today": db.query(func.count(ConnectionHistory.id)).filter(
                ConnectionHistory.start_at >= today_start
            ).scalar() or 0,
            "active_now": db.query(func.count(ConnectionHistory.id)).filter(
                ConnectionHistory.end_at == None
            ).scalar() or 0,
        },
        "wifi": {
            "active": db.query(func.count(WifiAccess.id)).filter(WifiAccess.active == True).scalar() or 0,
            "inactive": db.query(func.count(WifiAccess.id)).filter(WifiAccess.active == False).scalar() or 0,
        },
        "vouchers": {
            "total": db.query(func.count(Voucher.id)).scalar() or 0,
            "used": db.query(func.count(Voucher.id)).filter(Voucher.is_used == True).scalar() or 0,
            "available": db.query(func.count(Voucher.id)).filter(Voucher.is_used == False).scalar() or 0,
        },
        "revenue": {
            "total": db.query(func.coalesce(func.sum(Payment.amount), 0)).filter(
                Payment.status == "completed"
            ).scalar() or 0,
            "today": db.query(func.coalesce(func.sum(Payment.amount), 0)).filter(
                Payment.created_at >= today_start,
                Payment.status == "completed"
            ).scalar() or 0,
            "this_month": db.query(func.coalesce(func.sum(Payment.amount), 0)).filter(
                Payment.created_at >= month_start,
                Payment.status == "completed"
            ).scalar() or 0,
            "currency": "GNF"
        }
    }


# ============================================================
# 📈 GRAPHIQUE CONNEXIONS (7 derniers jours)
# ============================================================
@router.get("/connections/daily")
def get_daily_connections(
    days: int = 7,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Connexions par jour pour graphique en courbes"""
    
    result = []
    now = datetime.utcnow()
    
    for i in range(days - 1, -1, -1):
        day_start = datetime(now.year, now.month, now.day) - timedelta(days=i)
        day_end = day_start + timedelta(days=1)
        
        count = db.query(func.count(ConnectionHistory.id)).filter(
            ConnectionHistory.start_at >= day_start,
            ConnectionHistory.start_at < day_end
        ).scalar() or 0
        
        result.append({
            "date": day_start.strftime("%Y-%m-%d"),
            "label": day_start.strftime("%d/%m"),
            "connections": count
        })
    
    return {"data": result, "period": f"{days} jours"}


# ============================================================
# 📊 GRAPHIQUE UTILISATEURS (inscriptions)
# ============================================================
@router.get("/users/registrations")
def get_user_registrations(
    days: int = 30,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Inscriptions par jour pour graphique en barres"""
    
    result = []
    now = datetime.utcnow()
    
    for i in range(days - 1, -1, -1):
        day_start = datetime(now.year, now.month, now.day) - timedelta(days=i)
        day_end = day_start + timedelta(days=1)
        
        count = db.query(func.count(User.id)).filter(
            User.created_at >= day_start,
            User.created_at < day_end
        ).scalar() or 0
        
        result.append({
            "date": day_start.strftime("%Y-%m-%d"),
            "label": day_start.strftime("%d/%m"),
            "registrations": count
        })
    
    return {"data": result, "period": f"{days} jours"}


# ============================================================
# 📊 GRAPHIQUE REVENUS
# ============================================================
@router.get("/revenue/chart")
def get_revenue_chart(
    days: int = 30,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Revenus par jour pour graphique"""
    
    result = []
    now = datetime.utcnow()
    total = 0
    
    for i in range(days - 1, -1, -1):
        day_start = datetime(now.year, now.month, now.day) - timedelta(days=i)
        day_end = day_start + timedelta(days=1)
        
        amount = db.query(func.coalesce(func.sum(Payment.amount), 0)).filter(
            Payment.created_at >= day_start,
            Payment.created_at < day_end,
            Payment.status == "completed"
        ).scalar() or 0
        
        total += amount
        
        result.append({
            "date": day_start.strftime("%Y-%m-%d"),
            "label": day_start.strftime("%d/%m"),
            "amount": amount
        })
    
    return {
        "data": result,
        "total": total,
        "currency": "GNF",
        "period": f"{days} jours"
    }


# ============================================================
# 🔥 HEATMAP HEURES DE POINTE
# ============================================================
@router.get("/connections/heatmap")
def get_connections_heatmap(
    days: int = 7,
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Heatmap des connexions par heure et jour de la semaine"""
    
    now = datetime.utcnow()
    start_date = now - timedelta(days=days)
    
    # Matrice 7 jours x 24 heures
    heatmap = [[0 for _ in range(24)] for _ in range(7)]
    
    connections = db.query(ConnectionHistory).filter(
        ConnectionHistory.start_at >= start_date
    ).all()
    
    for conn in connections:
        day_of_week = conn.start_at.weekday()  # 0=Lundi, 6=Dimanche
        hour = conn.start_at.hour
        heatmap[day_of_week][hour] += 1
    
    # Trouver l'heure de pointe
    max_count = 0
    peak_day = 0
    peak_hour = 0
    
    for d in range(7):
        for h in range(24):
            if heatmap[d][h] > max_count:
                max_count = heatmap[d][h]
                peak_day = d
                peak_hour = h
    
    days_names = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
    
    return {
        "heatmap": heatmap,
        "days": days_names,
        "hours": list(range(24)),
        "peak": {
            "day": days_names[peak_day],
            "hour": f"{peak_hour}:00",
            "count": max_count
        },
        "period": f"{days} derniers jours"
    }


# ============================================================
# 🥧 RÉPARTITION DES VOUCHERS (Pie chart)
# ============================================================
@router.get("/vouchers/distribution")
def get_vouchers_distribution(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Répartition des vouchers par type (graphique circulaire)"""
    
    types = db.query(
        Voucher.type,
        func.count(Voucher.id).label("count")
    ).group_by(Voucher.type).all()
    
    total = sum(t[1] for t in types)
    
    return {
        "data": [
            {
                "type": t[0],
                "count": t[1],
                "percentage": round((t[1] / total * 100), 1) if total > 0 else 0
            }
            for t in types
        ],
        "total": total
    }


# ============================================================
# 📱 RÉPARTITION DES APPAREILS
# ============================================================
@router.get("/devices/distribution")
def get_devices_distribution(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Répartition des appareils par type"""
    
    types = db.query(
        Device.device_type,
        func.count(Device.id).label("count")
    ).group_by(Device.device_type).all()
    
    total = sum(t[1] for t in types if t[0])
    
    return {
        "data": [
            {
                "type": t[0] or "unknown",
                "count": t[1],
                "percentage": round((t[1] / total * 100), 1) if total > 0 else 0
            }
            for t in types
        ],
        "total": total
    }


# ============================================================
# 📊 STATS HEBDOMADAIRES COMPARÉES
# ============================================================
@router.get("/weekly-comparison")
def get_weekly_comparison(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Comparaison semaine actuelle vs semaine précédente"""
    
    now = datetime.utcnow()
    today_start = datetime(now.year, now.month, now.day)
    
    # Cette semaine
    this_week_start = today_start - timedelta(days=now.weekday())
    # Semaine dernière
    last_week_start = this_week_start - timedelta(days=7)
    last_week_end = this_week_start
    
    def get_week_stats(start, end):
        return {
            "connections": db.query(func.count(ConnectionHistory.id)).filter(
                ConnectionHistory.start_at >= start,
                ConnectionHistory.start_at < end
            ).scalar() or 0,
            "new_users": db.query(func.count(User.id)).filter(
                User.created_at >= start,
                User.created_at < end
            ).scalar() or 0,
            "vouchers_used": db.query(func.count(Voucher.id)).filter(
                Voucher.used_at >= start,
                Voucher.used_at < end
            ).scalar() or 0,
            "revenue": db.query(func.coalesce(func.sum(Payment.amount), 0)).filter(
                Payment.created_at >= start,
                Payment.created_at < end,
                Payment.status == "completed"
            ).scalar() or 0
        }
    
    this_week = get_week_stats(this_week_start, now)
    last_week = get_week_stats(last_week_start, last_week_end)
    
    def calc_change(current, previous):
        if previous == 0:
            return 100 if current > 0 else 0
        return round(((current - previous) / previous) * 100, 1)
    
    return {
        "this_week": this_week,
        "last_week": last_week,
        "changes": {
            "connections": calc_change(this_week["connections"], last_week["connections"]),
            "new_users": calc_change(this_week["new_users"], last_week["new_users"]),
            "vouchers_used": calc_change(this_week["vouchers_used"], last_week["vouchers_used"]),
            "revenue": calc_change(this_week["revenue"], last_week["revenue"])
        }
    }


# ============================================================
# 🌍 STATS PAR PAYS/RÉGION
# ============================================================
@router.get("/geographic")
def get_geographic_stats(
    db: Session = Depends(get_db),
    user: User = Depends(admin_required)
):
    """Statistiques par pays"""
    
    countries = db.query(
        User.country,
        func.count(User.id).label("users")
    ).group_by(User.country).all()
    
    return {
        "data": [
            {"country": c[0] or "Unknown", "users": c[1]}
            for c in countries
        ],
        "total_countries": len(countries)
    }

