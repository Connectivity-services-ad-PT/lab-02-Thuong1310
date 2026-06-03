le n# Phân tích yêu cầu — vai Consumer

- Cặp đàm phán: pair-07-camera-analytics-async
- Product: A / B
- Consumer service: Analytics
- Provider service: Camera Stream
- Người viết:
- Ngày:

---

## 1. Resource Consumer cần nhận/gửi

| Resource | Consumer dùng để làm gì? | Field bắt buộc với Consumer | Field có thể tùy chọn |
|---|---|---|---|
| `CameraMotionEvent` | Aggregate motion detection statistics | cameraId, timestamp, confidence, region | detectionId, imageRef |
| `CameraFrameAnalyzedEvent` | Track frame analysis result (object detection, etc) | cameraId, timestamp, analysisResult, detectionId | imageRef, metadata |
| `CameraStatusEvent` | Monitor camera health (online/offline/error) | cameraId, status, timestamp | signalStrength, lastFrame |

---

## 2. API Consumer cần gọi

| Method | Path | Lúc nào gọi? | Kỳ vọng response |
|---|---|---|---|
| Event | `camera.motion.detected` | Camera detect motion (abnormal activity) | Analytics consume & aggregate statistics |
| Event | `camera.frame.analyzed` | Camera analysis frame (object count, types) | Analytics store result, create dashboard |
| Event | `camera.status.changed` | Camera status change (online/offline/error) | Analytics update camera health dashboard |

---

## 3. Error case Consumer cần xử lý

Tối thiểu 5 case.

| Status | Consumer hiểu là gì? | Consumer sẽ xử lý thế nào? |
|---:|---|---|
| Sai schema event | Event payload không match schema (missing field, type wrong) | Log error, push to dead-letter queue |
| Thiếu cameraId | Không biết event từ camera nào | Log error, skip event, push to dead-letter |
| Invalid confidence | Confidence value không phải 0-1 hoặc missing | Log warning, skip hoặc use default value |
| Duplicate detectionId | Cùng detectionId nhận 2 lần | Idempotent check, skip nếu đã process |
| Queue timeout / broker offline | Analytics không kết nối queue | Retry, dead-letter queue, alert ops |

---

## 4. Giả định bổ sung

- Camera event publish qua message broker (Kafka recommended).
- Camera status: ONLINE, OFFLINE, ERROR, MAINTENANCE.
- Motion confidence: 0.0-1.0 (0 = no motion, 1 = certain motion).
- Frame analysis result: object type + count (vd: person=2, car=1, bag=0).
- Timestamp luôn ISO 8601 UTC.
- Analytics process event realtime hoặc batch per minute.
- Dead-letter queue để review event lỗi.

---

## 5. Câu hỏi cho Provider

1. Có gửi ảnh thật vào event không hay chỉ imageRef (URL)?
2. Motion event cần confidence score không? (để filter false positive)
3. Camera offline bao lâu thì sinh status.changed event? (immediate hay timeout 5min?)
4. Frame analyzed event có top-k object không? (vd: top 5 largest objects)
5. Analytics có cần realtime alert khi motion/object detected hay batch report? 

---

## 6. Rủi ro tích hợp

| Rủi ro | Tác động | Đề xuất xử lý |
|---|---|---|
| Image reference format khác (URL vs path vs base64) | Analytics không fetch image | Chốt format, provide base URL nếu relative |
| Confidence score missing hoặc > 1.0 | Analytics filter sai | Enforce 0.0-1.0 range, validate, dead-letter |
| Camera status enum khác (ON/OFF vs ONLINE/OFFLINE) | Analytics alert sai | Chốt enum: ONLINE, OFFLINE, ERROR, MAINTENANCE |
| High-volume frame events (30fps × 100 camera) → queue lag | Analytics late, miss realtime | Partition by cameraId, sample/skip frames |
| Duplicate detectionId do camera retry | Analytics count inflated | Idempotent by (cameraId + detectionId + timestamp) |
