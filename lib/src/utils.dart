library oss_flutter.utils;

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

const _EXTRA_TYPES_MAP = {
    ".jpg": "image/jpeg"
};

String httpDateNow(){
  final dt = new DateTime.now();
  initializeDateFormatting();
  final formatter = new DateFormat('EEE, d MMM yyyy HH:mm:ss', 'en_ISO');
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

