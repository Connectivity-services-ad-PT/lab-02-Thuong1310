#!/usr/bin/env bash
# ============================================================
# test_mock_with_curl.sh
# Test 5 requests mau - Smart Campus Core Business API (A6)
# ============================================================
set -e

BASE="http://localhost:4010"
TOKEN="Bearer lab-token"

echo "[Lab02] Testing Prism mock server at $BASE"
echo "============================================================"

echo ""
echo "[1/5] Happy path: GET /health"
curl -s -i "$BASE/health"
echo -e "\n---"

echo ""
echo "[2/5] Happy path: GET /access/logs/recent"
curl -s -i -H "Authorization: $TOKEN" "$BASE/access/logs/recent"
echo -e "\n---"

echo ""
echo "[3/5] Happy path: POST /access/check"
curl -s -i -X POST \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"requestId":"0196fb3d-4ad7-7d1e-9f49-5d5148d2cafe","cardId":"RFID88776655","gateId":"GATE-01","direction":"IN","timestamp":"2026-06-01T10:00:00Z"}' \
  "$BASE/access/check"
echo -e "\n---"

echo ""
echo "[4/5] Happy path: GET /cards/RFID88776655"
curl -s -i -H "Authorization: $TOKEN" "$BASE/cards/RFID88776655"
echo -e "\n---"

echo ""
echo "[5/5] Error case: GET /vision/detect/00000000-0000-0000-0000-000000000000 (not found)"
curl -s -i -H "Authorization: $TOKEN" \
  "$BASE/vision/detect/00000000-0000-0000-0000-000000000000"
echo -e "\n---"

echo ""
echo "============================================================"
echo "[Lab02] Done."