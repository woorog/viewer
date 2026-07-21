import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReaderTheme {
  static Future<void> apply(InAppWebViewController controller) async {
    await controller.evaluateJavascript(
      source: r'''
(function () {

  let style = document.getElementById("viewer-reader-theme");

  if (!style) {
    style = document.createElement("style");
    style.id = "viewer-reader-theme";
    document.head.appendChild(style);
  }

  style.innerHTML = `

  html{
      background:#111 !important;
  }

  body{

      background:#111 !important;

      color:#ECECEC !important;

      font-size:19px !important;

      line-height:2.0 !important;

      font-family:
      Pretendard,
      "Noto Sans KR",
      sans-serif !important;

      padding-left:22px !important;
      padding-right:22px !important;

      max-width:900px;
      margin:auto !important;
  }

  body *{

      background:transparent !important;

      color:inherit !important;
  }

  h1,h2,h3,h4,h5{

      color:white !important;
  }

  p{

      margin:1em 0;
  }

  a{

      color:#82B1FF !important;
  }

  img{

      max-width:100% !important;

      border-radius:8px;

      filter:brightness(.85);

      opacity:.95;
  }

  pre,
  code{

      background:#222 !important;

      color:#EEE !important;
  }

  blockquote{

      background:#1B1B1B !important;

      border-left:4px solid #555;

      padding:15px;
  }

  `;
})();
''',
    );
  }

  static Future<void> remove(InAppWebViewController controller) async {
    await controller.evaluateJavascript(
      source: """
document.getElementById("viewer-reader-theme")?.remove();
""",
    );
  }
}
