# bookItem.dart 🟢
<br>
Book 클래스를 만들어 main.dart에서 리스트 생성 후 다른 페이지들에서 사용.
Book 클래스를 만들어 데이터를 저장하는 포멧을 만드는 것이 중요한 부분이라고 생각됨.

```dart
import 'package:flutter/material.dart';

class Book {
  String? title;
  String? authors;
  String? sale_price;
  String? publisher;
  String? contents;
  String? thumbnail;
  Book({
    required this.thumbnail,
    required this.title,
    required this.authors,
    required this.sale_price,
    required this.publisher,
    this.contents
});
}
```