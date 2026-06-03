# Phân tích yêu cầu — vai Provider

- Cặp đàm phán: pair-07-camera-analytics-async
- Product: A / B
- Provider service: Camera Stream
- Consumer service: Analytics
- Người viết:
- Ngày:

---

## 1. Resource chính

| Resource | Mô tả | Thuộc tính bắt buộc | Thuộc tính tùy chọn |
|---|---|---|---|
| `CameraMotionEvent` | Sự kiện detect motion/abnormal activity | cameraId, timestamp, confidence, detectionId | region, imageRef, severity |
| `CameraFrameAnalyzedEvent` | Sự kiện analysis frame result (object detection) | cameraId, timestamp, analysisResult, detectionId | imageRef, metadata, topKObjects |
| `CameraStatusEvent` | Sự kiện status camera (online/offline/error) | cameraId, status, timestamp | signalStrength, lastFrame, errorCode |

---

## 2. Action/API dự kiến

| Method | Path | Mục đích | Consumer gọi khi nào? |
|---|---|---|---|
| Event | `camera.motion.detected` | Camera Stream phát event detect motion | Analytics consume để aggregate statistics, alert |
| Event | `camera.frame.analyzed` | Camera Stream phát event frame analyzed | Analytics store kết quả, build dashboard |
| Event | `camera.status.changed` | Camera Stream phát event status thay đổi | Analytics track camera health, alert offline |

---

## 3. Error case

Tối thiểu 5 case.

| Status | Tình huống | Response body dự kiến |
|---:|---|---|
| Message schema invalid | Event payload missing required field hay type sai | Dead-letter queue entry, log error detail |
| Missing cameraId | Event không có cameraId | Dead-letter queue, log "mandatory field missing" |
| Invalid confidence | Confidence > 1.0 hoặc < 0 | Dead-letter queue, log validation error |
| Duplicate detectionId | Cùng cameraId+detectionId gửi 2 lần | Analytics idempotent, no duplicate processing |
| Queue broker offline | Camera Stream không publish được | Retry logic, circuit breaker, alert ops |

---

## 4. Giả định bổ sung

Ghi rõ những điểm user story chưa nói nhưng Provider cần giả định.

- 100+ camera, each capture 30 fps (high volume).
- Camera Stream publish event qua message broker (Kafka).
- Motion confidence: 0.0-1.0 range.
- Frame analysis result: { "objects": [{"type": "person", "count": 2}, {"type": "car", "count": 1}] }.
- Camera status: ONLINE, OFFLINE, ERROR, MAINTENANCE.
- Timestamp luôn ISO 8601 UTC.
- Motion event: emit khi confidence > threshold (vd: 0.7).
- Frame analyzed event: emit mỗi N frame (vd: mỗi 30 frame = 1 second).
- Status event: emit khi status thay đổi hoặc timeout (vd: offline 5 min → event).

---

## 5. Câu hỏi cho Consumer

1. Analytics có cần full image data hay chỉ imageRef (URL) đủ k ?
2. Frame analyzed event có cần top-K object hay tất cả detected objects?
3. Analytics cần realtime alert khi motion detected hay batch report?
4. Confidence threshold nào Analytics sẽ trigger alert? (vd: > 0.8)
5. Analytics có deduplicate hoặc merge event từ cùng camera không? 

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Image include full frame base64 → oversized event | Queue lag, broker memory issue | Use imageRef (URL) only, not full image |
| Confidence score outside 0-1 range | Analytics filter/threshold sai | Validate, enforce range, dead-letter invalid |
| Status enum khác định nghĩa | Analytics alert logic sai | Chốt cụ thể: ONLINE, OFFLINE, ERROR, MAINTENANCE |
| High-volume frame event (3000 event/sec) → queue congestion | Analytics lag, miss realtime detection | Partition by cameraId, sample/throttle frames |
| Duplicate detectionId do network retry | Analytics count motion/object inflated | Idempotent by (cameraId + detectionId + timestamp) |
