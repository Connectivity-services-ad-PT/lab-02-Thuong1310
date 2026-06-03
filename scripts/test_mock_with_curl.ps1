# ============================================================
# Lab 02 - Smart Campus Core Business API (Nhom A6)
# Test script for Prism mock server at http://localhost:4010
# ============================================================

$BASE  = "http://localhost:4010"
$TOKEN = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test"

Write-Host "[Lab02] Testing Prism mock server at $BASE" -ForegroundColor Cyan
Write-Host "============================================================`n"

# ─────────────────────────────────────────────────────────────
# [1/5] Happy path: GET /health (no auth required)
# ─────────────────────────────────────────────────────────────
Write-Host "[1/5] Happy path: GET /health" -ForegroundColor Yellow
curl.exe -s -i "$BASE/health"
Write-Host "`n---`n"

# ─────────────────────────────────────────────────────────────
# [2/5] Happy path: GET /access/logs/recent
# ─────────────────────────────────────────────────────────────
Write-Host "[2/5] Happy path: GET /access/logs/recent" -ForegroundColor Yellow
curl.exe -s -i `
  -H "Authorization: $TOKEN" `
  "$BASE/access/logs/recent"
Write-Host "`n---`n"

# ─────────────────────────────────────────────────────────────
# [3/5] Happy path: POST /access/check (cardId hop le)
# ─────────────────────────────────────────────────────────────
Write-Host "[3/5] Happy path: POST /access/check" -ForegroundColor Yellow
curl.exe -s -i -X POST `
  -H "Authorization: $TOKEN" `
  -H "Content-Type: application/json" `
  -d "{""requestId"":""0196fb3d-4ad7-7d1e-9f49-5d5148d2cafe"",""cardId"":""RFID88776655"",""gateId"":""GATE-01"",""direction"":""IN"",""timestamp"":""2026-06-01T10:00:00Z""}" `
  "$BASE/access/check"
Write-Host "`n---`n"

# ─────────────────────────────────────────────────────────────
# [4/5] Error case: GET /cards/{cardId} hop le
# Expect: 200 OK voi thong tin the
# ─────────────────────────────────────────────────────────────
Write-Host "[4/5] Happy path: GET /cards/RFID88776655" -ForegroundColor Yellow
curl.exe -s -i `
  -H "Authorization: $TOKEN" `
  "$BASE/cards/RFID88776655"
Write-Host "`n---`n"

# ─────────────────────────────────────────────────────────────
# [5/5] Error case: GET /vision/detect/{requestId} khong ton tai
# Expect: 404 Not Found
# ─────────────────────────────────────────────────────────────
Write-Host "[5/5] Error case: GET /vision/detect/00000000-0000-0000-0000-000000000000 (not found)" -ForegroundColor Yellow
curl.exe -s -i `
  -H "Authorization: $TOKEN" `
  "$BASE/vision/detect/00000000-0000-0000-0000-000000000000"
Write-Host "`n---`n"

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "[Lab02] Done. Luu anh vao evidence/buoi-02/mock-screenshots/" -ForegroundColor Green