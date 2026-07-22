import os
import requests
from typing import Optional, Any, Dict, List
from .config import settings

class SupabaseClient:
    def __init__(self):
        self.url = os.getenv("SUPABASE_URL", "https://dgvtznykoyyxgwgtpbqf.supabase.co").rstrip("/")
        self.key = os.getenv("SUPABASE_ANON_KEY", "")

    @property
    def headers(self) -> Dict[str, str]:
        return {
            "apikey": self.key,
            "Authorization": f"Bearer {self.key}",
            "Content-Type": "application/json",
        }

    def select(self, table: str, query: str = "*") -> Optional[List[Dict[str, Any]]]:
        if not self.url or not self.key:
            return None
        try:
            res = requests.get(f"{self.url}/rest/v1/{table}?select={query}", headers=self.headers, timeout=3)
            if res.status_code == 200:
                return res.json()
        except Exception:
            pass
        return None

supabase = SupabaseClient()
