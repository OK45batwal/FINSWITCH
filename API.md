# FinSwitch API Documentation

**Base URL:** `https://api.finswitch.ai/api/v1`

## Authentication

All API requests require JWT Bearer token:
```
Authorization: Bearer <token>
```

### Auth Endpoints
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Create account |
| POST | `/auth/login` | Sign in |
| POST | `/auth/refresh` | Refresh token |
| POST | `/auth/logout` | Sign out |

## Markets

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/markets/indices` | All indices (Nifty, Sensex, Bank Nifty) |
| GET | `/markets/stocks` | Stock list with filters |
| GET | `/markets/stocks/{symbol}` | Stock detail + charts |
| GET | `/markets/gainers` | Top gainers |
| GET | `/markets/losers` | Top losers |
| GET | `/markets/heatmap` | Sector heatmap data |

## Portfolio

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/portfolio` | User portfolios |
| POST | `/portfolio` | Create portfolio |
| GET | `/portfolio/{id}` | Portfolio detail |
| GET | `/portfolio/{id}/holdings` | Holdings list |
| POST | `/portfolio/{id}/holdings` | Add holding |
| GET | `/portfolio/{id}/transactions` | Transaction history |
| GET | `/portfolio/analysis` | AI portfolio analysis |

## News

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/news` | News feed (paginated, filterable) |
| GET | `/news/{id}` | News article detail |
| GET | `/news/{id}/ai-summary` | AI-generated summary |

## AI

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/ai/chat` | Send message to AI Copilot |
| GET | `/ai/chats` | Chat history |
| GET | `/ai/chats/{id}` | Single chat detail |
| POST | `/ai/analyze/stock` | AI stock analysis |
| POST | `/ai/analyze/portfolio` | AI portfolio analysis |
| POST | `/ai/compare` | Compare companies |
| POST | `/ai/summarize` | General AI summary |

## Watchlist

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/watchlist` | User watchlists |
| POST | `/watchlist` | Create watchlist |
| GET | `/watchlist/{id}` | Watchlist detail |
| POST | `/watchlist/{id}/items` | Add item |
| DELETE | `/watchlist/{id}/items/{item_id}` | Remove item |

## Alerts

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/alerts` | User alerts |
| POST | `/alerts` | Create alert |
| PUT | `/alerts/{id}` | Update alert |
| DELETE | `/alerts/{id}` | Delete alert |

## SIP Plans

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/sip` | SIP plans |
| POST | `/sip` | Create plan |
| GET | `/sip/{id}` | Plan detail |
| POST | `/sip/calculate` | Calculate SIP |

## Learning

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/learning/courses` | All courses |
| GET | `/learning/courses/{id}` | Course detail |
| GET | `/learning/courses/{id}/modules` | Course modules |
| POST | `/learning/progress` | Update progress |
| GET | `/learning/progress` | User progress |

## Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/users/me` | Current user |
| PUT | `/users/me` | Update profile |
| PUT | `/users/me/preferences` | Update preferences |

### Response Format
```json
{
  "success": true,
  "data": {},
  "message": "Success",
  "error": null
}
```

### Error Format
```json
{
  "success": false,
  "data": null,
  "message": "Error description",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": {}
  }
}
```
