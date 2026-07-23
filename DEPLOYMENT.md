# FinSwitch Deployment Strategy

## Infrastructure

```
┌────────────────────────────────────────────────────┐
│                    Cloudflare                        │
│     DNS · CDN · DDoS Protection · Cloudflare Pages   │
└──────────────────┬─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│                Cloudflare Edge / Workers             │
│  ┌─────────────┐ ┌─────────────┐ ┌──────────────┐ │
│  │ API Workers │ │ API Workers │ │  API Workers │ │
│  └─────────────┘ └─────────────┘ └──────────────┘ │
└──────────────────┬─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│                 Supabase Platform                    │
│   PostgreSQL DB │ Supabase Auth │ Storage Buckets   │
│   (Row Security)│ (JWT / OAuth) │ (Assets & Media)  │
└────────────────────────────────────────────────────┘
```

## Mobile App Deployment

### Android (Auto-Update & Release Key Signing)
- Build: `flutter build apk --release` (or `appbundle`)
- Target: Android 8.0+ (API 26)
- Features: Material 3, In-App Auto-Updater with SHA-256 Checksum Verification & Streamed File Installation
- Persistent Keystore Signing Secrets in GitHub Actions:
  - `RELEASE_KEYSTORE_BASE64`: Base64 encoded `release.keystore` file
  - `RELEASE_KEYSTORE_PASSWORD`: Keystore password
  - `RELEASE_KEY_ALIAS`: Key alias
  - `RELEASE_KEY_PASSWORD`: Key password

### iOS (Apple App Store)
- Build: `flutter build ios --release`
- Target: iOS 15+
- Features: SF Symbols, Haptic feedback, Widget support

## Web Deployment

- **Landing Site:** Cloudflare Pages (static)
- **Admin Panel:** Cloudflare Pages (SPA)
- **API:** Cloudflare Workers & Supabase Edge Functions
- **Database & Auth:** Supabase (Managed PostgreSQL & Auth)

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

- **Errors:** Sentry (mobile + website)
- **Performance:** Datadog / New Relic
- **Uptime:** Better Uptime / Pingdom
- **Analytics:** Mixpanel / Firebase Analytics
- **Metrics:** Cloudflare and Supabase dashboards

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
| Cloudflare Workers & Pages | $0 - $5 | Free tier / Workers Paid |
| Supabase Pro (PostgreSQL + Auth + Storage) | $25 | Managed PostgreSQL + Auth |
| Upstash Redis | $0 - $5 | Rate limiting & cache |
| Cloudflare DNS & CDN | Free | Free tier |
| Sentry | Free tier | Error monitoring |
| Total | ~$25 - $35/mo | Startup phase |
