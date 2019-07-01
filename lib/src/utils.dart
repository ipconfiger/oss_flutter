library oss_flutter.utils;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

const _EXTRA_TYPES_MAP = {".aac": "audio/aac", ".abw": "application/x-abiword", ".arc": "application/x-freearc", ".avi": "video/x-msvideo", ".azw": "application/vnd.amazon.ebook", ".bin": "application/octet-stream", ".bmp": "image/bmp", ".bz": "application/x-bzip", ".bz2": "application/x-bzip2", ".csh": "application/x-csh", ".css": "text/css", ".csv": "text/csv", ".doc": "application/msword", ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document", ".eot": "application/vnd.ms-fontobject", ".epub": "application/epub+zip", ".gif": "image/gif", ".htm": "text/html", ".html": "text/html", ".ico": "image/vnd.microsoft.icon", ".ics": "text/calendar", ".jar": "application/java-archive", ".jpeg": "image/jpeg", ".jpg": "image/jpeg", ".js": "text/javascript", ".json": "application/json", ".jsonld": "application/ld+json", ".mp3": "audio/mpeg", ".mpeg": "video/mpeg", ".mpkg": "application/vnd.apple.installer+xml", ".odp": "application/vnd.oasis.opendocument.presentation", ".ods": "application/vnd.oasis.opendocument.spreadsheet", ".odt": "application/vnd.oasis.opendocument.text", ".oga": "audio/ogg", ".ogv": "video/ogg", ".ogx": "application/ogg", ".otf": "font/otf", ".png": "image/png", ".pdf": "application/pdf", ".ppt": "application/vnd.ms-powerpoint", ".pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation", ".rar": "application/x-rar-compressed", ".rtf": "application/rtf", ".sh": "application/x-sh", ".svg": "image/svg+xml", ".swf": "application/x-shockwave-flash", ".tar": "application/x-tar", ".tif": "image/tiff", ".tiff": "image/tiff", ".ts": "video/mp2t", ".ttf": "font/ttf", ".txt": "text/plain", ".vsd": "application/vnd.visio", ".wav": "audio/wav", ".weba": "audio/webm", ".webm": "video/webm", ".webp": "image/webp", ".woff": "font/woff", ".woff2": "font/woff2", ".xhtml": "application/xhtml+xml", ".xls": "application/vnd.ms-excel", ".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", ".xul": "application/vnd.mozilla.xul+xml", ".zip": "application/zip", ".3gp": "video/3gpp", ".3g2": "video/3gpp2"};

String httpDateNow(){
  final dt = new DateTime.now();
  initializeDateFormatting();
  final formatter = new DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_ISO');
  final dts = formatter.format(dt.toUtc());
  return "${dts} GMT";
}

String contentTypeByFilename(String filename){
  final seqs = filename.split('.');
  final ext = seqs[seqs.length -1];
  return _EXTRA_TYPES_MAP['.${ext}'];
}

String hmacSign(String secret, String raw){
  var hmac = new Hmac(sha1, utf8.encode(secret));
  final digest = hmac.convert(utf8.encode(raw));
  return base64Encode(digest.bytes);
}

String md5File(List<int> fileData){
  var digest = md5.convert(fileData);
  // 这里其实就是 digest.toString()
  return base64Encode(digest.bytes);
}

