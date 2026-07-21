# FinSwitch Architecture

## System Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Clients                           │
│  Flutter App (iOS/Android)  │  Web (Landing/Admin)  │
└────────────────────┬────────────────────────────────┘
                     │ HTTPS / WSS
┌────────────────────▼────────────────────────────────┐
│              API Gateway / Load Balancer              │
│                    (nginx)                            │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│                  FastAPI Server                       │
│  ┌────────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │ Auth Routes│ │API Routes│ │  Middleware       │  │
│  │ JWT/OAuth  │ │  REST    │ │  CORS/RateLimit  │  │
│  └────────────┘ └──────────┘ └──────────────────┘  │
│  ┌────────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │ Services   │ │  Models  │ │  Background Jobs │  │
│  │ AI Service │ │ SQLAlch. │ │  Celery Workers  │  │
│  └────────────┘ └──────────┘ └──────────────────┘  │
└──┬──────────────┬────────────────┬──────────────────┘
   │              │                │
   ▼              ▼                ▼
┌──────┐    ┌────────┐     ┌──────────┐
│Redis │    │Postgres│     │ Celery   │
│Cache │    │  Main  │     │ Workers  │
│Session│    │  DB    │     │   │      │
└──────┘    └────────┘     └───┼──────┘
                                │
                          ┌─────▼─────┐
                          │  External │
                          │  APIs     │
                          │NSE/BSE/.. │
                          └───────────┘
```

## Folder Structure

### Backend (Feature-first)
```
backend/app/
├── api/v1/         # Route handlers per feature
├── core/           # Config, security, database
├── models/         # SQLAlchemy ORM models
├── schemas/        # Pydantic request/response
├── services/       # Business logic layer
└── workers/        # Async/Celery background tasks
```

### Flutter (Feature-first)
```
flutter_app/lib/
├── app/            # App shell, theme, router
│   ├── config/     # Theme, router config
│   └── widgets/    # Shared widgets
├── core/           # Cross-cutting concerns
│   ├── constants/  # API endpoints, app constants
│   ├── network/    # HTTP client, interceptors
│   ├── storage/    # Secure storage, local cache
│   └── utils/      # Helpers, extensions
└── features/       # Feature modules
    ├── home/
    │   ├── presentation/  # UI screens, widgets
    │   ├── data/          # Repositories, data sources
    │   └── domain/        # Models, use cases
    ├── markets/
    ├── news/
    ├── ai/
    └── portfolio/
```

## Design Principles

1. **Clean Architecture** - Separation of concerns across layers
2. **Feature-first** - Each feature is self-contained
3. **Repository Pattern** - Data abstraction layer
4. **Riverpod** - Dependency injection and state management
5. **SOLID** - Single responsibility, Open/closed, etc.

## Key Decisions

- **PostgreSQL** over NoSQL for relational financial data and ACID compliance
- **Redis** for real-time market data caching
- **FastAPI** for async performance with Python
- **Celery** for background market data ingestion
- **Firebase Auth** + JWT for flexible authentication
- **Riverpod** over BLoC for simpler state management in Flutter
