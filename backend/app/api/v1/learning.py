from fastapi import APIRouter, Depends

router = APIRouter(prefix="/learning", tags=["Learning"])

COURSES = [
    {"id": "1", "title": "Stock Market Basics", "slug": "stock-market-basics", "category": "stocks", "difficulty": "beginner", "duration_minutes": 120, "modules": 8, "description": "Learn how the stock market works, key terminology, and how to start your investment journey."},
    {"id": "2", "title": "Fundamental Analysis", "slug": "fundamental-analysis", "category": "stocks", "difficulty": "intermediate", "duration_minutes": 180, "modules": 12, "description": "Master financial statements, ratios, and valuation techniques to pick winning stocks."},
    {"id": "3", "title": "Mutual Funds Simplified", "slug": "mutual-funds-simplified", "category": "mutual_funds", "difficulty": "beginner", "duration_minutes": 90, "modules": 6, "description": "Everything you need to know about mutual funds, SIPs, and portfolio allocation."},
    {"id": "4", "title": "Technical Analysis", "slug": "technical-analysis", "category": "stocks", "difficulty": "advanced", "duration_minutes": 240, "modules": 15, "description": "Charts, patterns, indicators, and trading strategies for the active investor."},
    {"id": "5", "title": "Personal Finance 101", "slug": "personal-finance-101", "category": "finance", "difficulty": "beginner", "duration_minutes": 60, "modules": 5, "description": "Budgeting, saving, investing, insurance, and tax planning for financial wellness."},
]


@router.get("/courses")
async def get_courses():
    return {"success": True, "data": COURSES}


@router.get("/courses/{course_id}")
async def get_course_detail(course_id: str):
    course = next((c for c in COURSES if c["id"] == course_id), None)
    if not course:
        return {"success": False, "error": "Course not found"}
    return {"success": True, "data": {**course, "content": "Full course content would be loaded here."}}


@router.get("/courses/{course_id}/modules")
async def get_course_modules(course_id: str):
    return {"success": True, "data": [{"id": f"m{i}", "title": f"Module {i}", "duration_minutes": 15, "content_type": "article"} for i in range(1, 6)]}
