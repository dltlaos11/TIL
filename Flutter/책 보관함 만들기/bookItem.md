# bookItem.dart ๐ข
<br>
Book ํด๋์ค๋ฅผ ๋ง๋ค์ด main.dart์์ ๋ฆฌ์คํธ ์์ฑ ํ ๋ค๋ฅธ ํ์ด์ง๋ค์์ ์ฌ์ฉ.
Book ํด๋์ค๋ฅผ ๋ง๋ค์ด ๋ฐ์ดํฐ๋ฅผ ์ ์ฅํ๋ ํฌ๋ฉง์ ๋ง๋๋ ๊ฒ์ด ์ค์ํ ๋ถ๋ถ์ด๋ผ๊ณ  ์๊ฐ๋จ.

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