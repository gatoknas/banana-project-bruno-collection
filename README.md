# Banana Project API — Bruno Collection

Hand-authored [Bruno](https://www.usebruno.com/) requests for the Banana Project Go REST API.

## Import

1. Open Bruno and import this folder (`banana-project-bruno-collection`) as a collection.
2. Select an environment:
   - **Local** → `{{base_url}}` = `http://localhost:8082`
   - **production** → `{{base_url}}` = `https://api.ayurami.com`

The collection is registered as a folder in `../banana-project.code-workspace`, so it is a
workspace root when that multi-root workspace is open in the IDE.

## Environments

`{{base_url}}` is defined per environment (`environments/*.bru`). `{{user_id}}`,
`{{product_id}}`, `{{supplier_id}}`, and `{{purchase_id}}` are also there and default to `1`.
`{{token}}` and `{{refreshToken}}` are runtime variables captured by the **Login** request's post-response script — never commit them.

## Auth flow

1. Run **Login** (`POST /login`). Its script stores `token` and `refreshToken`.
2. Every `/api/v1/*` request sends `Authorization: Bearer {{token}}` (`auth: inherit`).
3. Run **Refresh Token** (`POST /refresh`) to rotate both variables when the access token expires.

## Requests (seq order)

Status, Hello, Login, Refresh Token, Create/List/Get/Update/Delete User, Get Categories,
Create/Get/Get-by-id/Update/Delete Product, Create Sale, Sync/List Email Receipts, Get Revenue Summary,
PROD Hello, Get Units of Measure, Create/List/Get/Update/Delete Supplier, Create/List/Get Purchase.

## Keeping it in sync

`banana-project-go-api/docs/swagger.json` is the **source of truth**. After an API endpoint is
added or changed, add/update the matching `.bru` here and run:

```powershell
pwsh -File scripts/check-sync.ps1
```

The script compares every spec operation against the collection and exits non-zero on any
`MISSING` (spec operation with no request) or `ORPHAN` (request not in the spec). It maps path
parameters structurally (`{id}` ⇄ `{{product_id}}` ⇄ `1`) and skips absolute-host requests
(`PROD Hello.bru`) and intentionally omitted helpers (`GET /hello/logo.png`, `/docs`).

## Notes

- The API must be running (`go run ./cmd/api` from `banana-project-go-api`) and Postgres must be
  up for any authenticated request.
- The email-receipt endpoints require Gmail credentials on the API; without them the sync
  request returns an error by design.
