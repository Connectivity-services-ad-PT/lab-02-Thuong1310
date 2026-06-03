#!/usr/bin/env bash
# ============================================================
# collect_session02_evidence.sh
# Thu thap bang chung buoi 02: chay mock server + 5 curl test
# Smart Campus Core Business API - Nhom A6
# ============================================================
set -e

BASE="http://localhost:4010"
TOKEN="Bearer lab-token"
EVIDENCE_DIR="evidence/buoi-02/mock-screenshots"
mkdir -p "$EVIDENCE_DIR"

echo "============================================================"
echo "[Lab02] Collecting evidence against Prism mock at $BASE"
echo "============================================================"

# ── [1/5] GET /health ───────────────────────────────────────
echo ""
echo "[1/5] Happy path: GET /health"
curl -s -i "$BASE/health" | tee "$EVIDENCE_DIR/01_health_200.txt"
echo ""
echo "---"

# ── [2/5] GET /access/logs/recent ───────────────────────────
echo ""
echo "[2/5] Happy path: GET /access/logs/recent"
curl -s -i \
  -H "Authorization: $TOKEN" \
  "$BASE/access/logs/recent" | tee "$EVIDENCE_DIR/02_access_logs_200.txt"
echo ""
echo "---"

# ── [3/5] POST /access/check (happy path) ───────────────────
echo ""
echo "[3/5] Happy path: POST /access/check"
curl -s -i -X POST \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"requestId":"0196fb3d-4ad7-7d1e-9f49-5d5148d2cafe","cardId":"RFID88776655","gateId":"GATE-01","direction":"IN","timestamp":"2026-06-01T10:00:00Z"}' \
  "$BASE/access/check" | tee "$EVIDENCE_DIR/03_access_check_200.txt"
echo ""
echo "---"

# ── [4/5] GET /cards/RFID88776655 (happy path) ──────────────
echo ""
echo "[4/5] Happy path: GET /cards/RFID88776655"
curl -s -i \
  -H "Authorization: $TOKEN" \
  "$BASE/cards/RFID88776655" | tee "$EVIDENCE_DIR/04_card_detail_200.txt"
echo ""
echo "---"

# ── [5/5] GET /vision/detect/{id} not found ─────────────────
echo ""
echo "[5/5] Error case: GET /vision/detect/00000000-0000-0000-0000-000000000000"
curl -s -i \
  -H "Authorization: $TOKEN" \
  "$BASE/vision/detect/00000000-0000-0000-0000-000000000000" | tee "$EVIDENCE_DIR/05_vision_detect_404.txt"
echo ""
echo "---"

echo ""
echo "============================================================"
echo "[Lab02] Done. Evidence saved to $EVIDENCE_DIR/"
ls -la "$EVIDENCE_DIR/"
echo "============================================================"