
# health_sleep_reader

Health Sleep Reader là một ứng dụng Flutter nhỏ giúp đọc và hiển thị dữ liệu giấc ngủ từ thiết bị (thông qua Health Connect trên Android).

Ứng dụng tập trung vào:
- Kiểm tra trạng thái Health Connect (hoặc HealthKit tương đương).
- Yêu cầu quyền truy cập dữ liệu giấc ngủ.
- Lấy dữ liệu giấc ngủ trong 7 ngày gần nhất và hiển thị theo danh sách.

## Tính năng chính
- Kiểm tra trạng thái của Health Connect (installed / not installed / checking).
- Yêu cầu và kiểm tra quyền đọc dữ liệu giấc ngủ.
- Lấy và lọc các session ngủ (sleep sessions) trong 7 ngày gần nhất.
- Hiển thị: thời gian bắt đầu/kết thúc, tổng thời gian ngủ, ngày.

## Kiến trúc & thư viện chính
- Ngôn ngữ: Dart + Flutter
- Quản lý trạng thái: `provider`
- Truy xuất dữ liệu sức khỏe: package `health` (giao tiếp Health Connect / HealthKit)

Các file chính:
- `lib/main.dart`: khởi tạo app, cấu hình locale.
- `lib/controller/main_controller.dart`: logic chính — kiểm tra trạng thái Health Connect, quyền, và lấy dữ liệu ngủ.
- `lib/screens/main_screen.dart`: giao diện hiển thị các trạng thái và danh sách session ngủ.

## Yêu cầu
- Flutter SDK (phiên bản tương thích với `sdk` trong `pubspec.yaml`).
- Thiết bị Android có hỗ trợ Health Connect.

Lưu ý: Trên Android, ứng dụng kiểm tra Health Connect SDK và có nút mở để cài Health Connect nếu chưa cài.
## Hướng dẫn chạy nhanh

1) Lấy dependency:

```bash
flutter pub get
```

2) Chạy ứng dụng trên thiết bị (Android):

```bash
flutter run
```

Trên Android: chạy trên thiết bị thật sẽ cho phép kiểm tra Health Connect. Nếu Health Connect chưa cài, app sẽ hiển thị nút "Install Health Connect".

## Quyền và các bước cần làm khi chạy
- Khi app yêu cầu quyền, hãy cho phép quyền đọc dữ liệu giấc ngủ.
- Nếu app báo `Health Connect is required`, bạn cần cài đặt ứng dụng Health Connect từ Play Store.

## Khắc phục sự cố nhanh
- Không thấy dữ liệu: kiểm tra đã cấp quyền chưa, và dữ liệu giấc ngủ có tồn tại trên thiết bị hay không.
- Lỗi kết nối Health Connect: kiểm tra phiên bản Android và xem Health Connect đã cài và cập nhật chưa.


## License
This project is licensed under the MIT License.

MIT License
Copyright (c) 2025 Phan Quang Duy

