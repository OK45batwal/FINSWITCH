# FinSwitch Deployment Strategy

## Infrastructure

```
┌────────────────────────────────────────────────────┐
│                    Cloudflare                        │
│           DNS · CDN · DDoS Protection               │
└──────────────────┬─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│              AWS / GCP Load Balancer                 │
└──────────────────┬─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│                   ECS / GKE                          │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ │
│  │ API Server  │ │ API Server  │ │  API Server  │ │
│  │ (AutoScale) │ │ (AutoScale) │ │  (AutoScale) │ │
│  └─────────────┘ └─────────────┘ └──────────────┘ │
└──────────────────┬─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│   RDS (PostgreSQL) │ ElastiCache (Redis) │ S3      │
│   Multi-AZ         │ Cluster Mode        │ Assets  │
└────────────────────────────────────────────────────┘
```

## Mobile App Deployment

### Android (Google Play Store)
- Build: `flutter build appbundle --release`
- Target: Android 8.0+ (API 26)
- Features: Material 3, Edge-to-edge, Dynamic colors

### iOS (Apple App Store)
- Build: `flutter build ios --release`
- Target: iOS 15+
- Features: SF Symbols, Haptic feedback, Widget support

## Web Deployment

- **Landing Site:** Cloudflare Pages (static)
- **Admin Panel:** Cloudflare Pages (SPA)
- **API:** Docker containers on ECS/GKE

## CI/CD Pipeline

```
Git Push → GitHub Actions
  ├── Lint & Type Check
  ├── Run Tests
  ├── Build App
  ├── Deploy to Staging
  ├── Integration Tests
  └── Deploy to Production
```

## Monitoring

- **Errors:** Sentry (mobile + backend)
- **Performance:** Datadog / New Relic
- **Uptime:** Better Uptime / Pingdom
- **Analytics:** Mixpanel / Firebase Analytics
- **Metrics:** Prometheus + Grafana (backend)

## Security Checklist

- [x] HTTPS enforced everywhere
- [x] JWT with short expiry + refresh tokens
- [x] Rate limiting on all API endpoints
- [x] Input validation at every boundary
- [x] SQL injection protection (ORM)
- [x] XSS protection (CSP headers)
- [x] CORS restricted to known origins
- [x] Secrets in environment variables
- [x] Database encryption at rest
- [x] Audit logging for sensitive actions

## Costs (Estimated Monthly)

| Service | Cost | Notes |
|---------|------|-------|
| API Servers (3x t3.medium) | ~$150 | Auto-scaling |
| RDS PostgreSQL (db.t3.medium) | ~$80 | Multi-AZ |
| ElastiCache Redis (cache.t3.micro) | ~$20 | |
| Cloudflare Pro | $20 | CDN + DNS |
| Sentry | Free tier | |
| Total | ~$270/mo | Startup phase |
