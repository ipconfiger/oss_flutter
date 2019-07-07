library oss_flutter.test.impl_test;

import 'dart:convert';
import 'dart:io';
import "package:test/test.dart";
import 'package:oss_flutter/src/utils.dart';
import 'package:oss_flutter/oss_flutter.dart';

void main() {
  HttpRequest req = new HttpRequest(
          'https://messenger.miaomi.co',
          'GET',
          {'versions':'xx', 'link':'yy'},
          {'x-oss-content-type':'application/json', 'x-oss-content-md5': 'adasdasdasdasdasdadasd'});
        Auth auth = new Auth('asdad', 'a3ffwefefew', 'asdadasdas');

  group('Utils', (){
    test('httpDate', (){
      final ds = httpDateNow();
      print(ds);
      expect(true, equals(true));
    });
    test('Auth-_get_subresource_string',(){
      final param = auth.get_subresource_string(req.param);
      print('param->${param}');
      expect(true, equals(param == '?link=yy&versions=xx'));
    });
    test('Auth-get_headers_string', (){
      final headerStr = auth.get_headers_string(req);
      print('headers->\n${headerStr}');
      final eqResult = "x-oss-content-md5:adasdasdasdasdasdadasd\nx-oss-content-type:application/json\n";
      expect(true, equals(eqResult == headerStr));
    });
    test('Auth-get_resource_string', (){
      final resource = auth.get_resource_string(req, "atk-tmp", '');
      print('res: ${resource}');
      final eqStr = '/atk-tmp/?link=yy&versions=xx';
      expect(true, equals(resource == eqStr));
    });
    test('Auth-get_string_to_sign', (){
      final signRaw = auth.get_string_to_sign(req, "atk-tmp", '');
      print("raw:\n${signRaw}");
      expect(true, equals(true));
    });

    test('Client-checkExpire', (){
        final client = Client('', '', (url) async{});
        final yes = client.checkExpire('2019-06-23T00:53:26Z');
        print('rs:${yes}');
        expect(true, equals(yes));
    });
    test('Client-Auth', () async{
      final client = Client('', '', (url) async{
          return '{'
            '"AccessKeyId": "STS.NK8DkLweZY6juxjTaXSDtEhFT",'
            '"AccessKeySecret": "DmZryEAFYijzndptHoukoYXPTY9NeinBZrLrQKMGaLHt",'
            '"Expiration": "2019-06-23T00:53:26Z",'
            '"SecurityToken": "CAIS9gF1q6Ft5B2yfSjIr4iND9H4mrp77vSBd17bsGENX8tYqq3ttjz2IH9OeHhqB+kWsPkyn2FW7fwalrh+W4NIX0rNaY5t9ZlN9wqkbtJqfW9TPflW5qe+EE2/VjTZvqaLEcibIfrZfvCyESOm8gZ43br9cxi7QlWhKufnoJV7b9MRLGLaBHg8c7UwHAZ5r9IAPnb8LOukNgWQ4lDdF011oAFx+wgdgOadupDGtUOC0QCilrZM99yre8WeApMybMcvYbCcx/drc6fN6ilU5iVR+b1+5K4+omid4oDHXQABvUjbaLuKqYc3NmF+fbMzEKVUczQjVFHbfI0agAGLEH6WkWif+jfTBZ2OEGaPNw+2HPhdnqtfP7gawuDvN72xeN2KtJZKH0vAi3cTGId0rlb0drO0KvYVUGtyyvkYDLDEzJC1gDYl/ewuknqnJYJyxegCc/J3YDiFpCCbQ2kK9464A+os5Y7TGa+RUKF+6kbkuwu+hMRL+aJWJZUjGA==",'
            '"StatusCode": 200'
          '}';
        });
        await client.getAuth();
        expect(true, equals(client.checkAuthed()));
    });
    test('Client-listBucket', () async{
      //final client = Client('', 'oss-cn-hongkong.aliyuncs.com', (url) async{
      //    return '{"AccessKeyId": "STS.NHYAwHswkpGL3zmbhH9ft8wHx","AccessKeySecret": "6VoWFA28X57dJvMH7SdacfVS7RTUVv6hshFPQePDoyBi","Expiration": "2019-07-01T10:00:03Z","SecurityToken": "CAIS9gF1q6Ft5B2yfSjIr4vsCs38nqhKx4WnMVzchmgdNelY17Ljmjz2IH9OeHhqB+kWsPkyn2FW7fwalrh+W4NIX0rNaY5t9ZlN9wqkbtI9GUw6P/lW5qe+EE2/VjTZvqaLEcibIfrZfvCyESOm8gZ43br9cxi7QlWhKufnoJV7b9MRLGLaBHg8c7UwHAZ5r9IAPnb8LOukNgWQ4lDdF011oAFx+wgdgOadupDGtUOC0QCilrZM99yre8WeApMybMcvYbCcx/drc6fN6ilU5iVR+b1+5K4+omid4oDHXQABvUjbaLuKqYc3NmF+fbMzEKVUczQjVFHbfI0agAF9p7CzF/v3kHvr+1hhEw8w842kZhjkVKTsb/Ir+MP65jXN+F3732OKrHN1Q80tZaMdP7SkSmml/paSXE9yrfcflNKk//EHNo8UcESLfA1Pg+MQPCVWxtvtqHCgHlEuWZV1pfovrsw4+6wF8FBkFn1u/KKLbyCKZthM/48an8XXsA==","StatusCode": 200}';
      //});
      final client = new Client.static('LTAIqgK3juTxj2ty', 'ojJd18CAA2heIA9E96NIvmQgnbPCig', 'cn-hongkong');
      final request = client.list_buckets();
      print(request.asCurl());
      expect(true, equals(true));
    });

    test('Client-md5file', () async{
      File f = new File('/Users/alex/Pictures/1.jpg');
      final bytes = await f.readAsBytes();
      final hashValue = md5File(bytes);
      final checkValue = '8d90a8c48d0e8427335787903f52e1c9';
      print('hash:${hashValue}   to  ${checkValue}');
      expect(true, equals(hashValue == checkValue));
    });
    test('Client-putObject', () async{
      final path = '/Users/alex/Pictures/1.jpg';
      File f = new File(path);
      final bytes = await f.readAsBytes();
      final client = Client('', 'oss-cn-hongkong.aliyuncs.com', (url) async{
          return '{'
            '"AccessKeyId": "STS.NK8DkLweZY6juxjTaXSDtEhFT",'
            '"AccessKeySecret": "DmZryEAFYijzndptHoukoYXPTY9NeinBZrLrQKMGaLHt",'
            '"Expiration": "2019-06-23T00:53:26Z",'
            '"SecurityToken": "CAIS9gF1q6Ft5B2yfSjIr4iND9H4mrp77vSBd17bsGENX8tYqq3ttjz2IH9OeHhqB+kWsPkyn2FW7fwalrh+W4NIX0rNaY5t9ZlN9wqkbtJqfW9TPflW5qe+EE2/VjTZvqaLEcibIfrZfvCyESOm8gZ43br9cxi7QlWhKufnoJV7b9MRLGLaBHg8c7UwHAZ5r9IAPnb8LOukNgWQ4lDdF011oAFx+wgdgOadupDGtUOC0QCilrZM99yre8WeApMybMcvYbCcx/drc6fN6ilU5iVR+b1+5K4+omid4oDHXQABvUjbaLuKqYc3NmF+fbMzEKVUczQjVFHbfI0agAGLEH6WkWif+jfTBZ2OEGaPNw+2HPhdnqtfP7gawuDvN72xeN2KtJZKH0vAi3cTGId0rlb0drO0KvYVUGtyyvkYDLDEzJC1gDYl/ewuknqnJYJyxegCc/J3YDiFpCCbQ2kK9464A+os5Y7TGa+RUKF+6kbkuwu+hMRL+aJWJZUjGA==",'
            '"StatusCode": 200'
          '}';
        });
      await client.getAuth();
      HttpRequest req = client.putObject(bytes, 'messenger', '1.jpg');
      print(req.asCurl(file_path: path));
      expect(true, equals(true));      
    });
    test('Client-deleteObject', () async{
      final client = Client('', 'oss-cn-hongkong.aliyuncs.com', (url) async{
          return '{'
            '"AccessKeyId": "STS.NK8DkLweZY6juxjTaXSDtEhFT",'
            '"AccessKeySecret": "DmZryEAFYijzndptHoukoYXPTY9NeinBZrLrQKMGaLHt",'
            '"Expiration": "2019-06-23T00:53:26Z",'
            '"SecurityToken": "CAIS9gF1q6Ft5B2yfSjIr4iND9H4mrp77vSBd17bsGENX8tYqq3ttjz2IH9OeHhqB+kWsPkyn2FW7fwalrh+W4NIX0rNaY5t9ZlN9wqkbtJqfW9TPflW5qe+EE2/VjTZvqaLEcibIfrZfvCyESOm8gZ43br9cxi7QlWhKufnoJV7b9MRLGLaBHg8c7UwHAZ5r9IAPnb8LOukNgWQ4lDdF011oAFx+wgdgOadupDGtUOC0QCilrZM99yre8WeApMybMcvYbCcx/drc6fN6ilU5iVR+b1+5K4+omid4oDHXQABvUjbaLuKqYc3NmF+fbMzEKVUczQjVFHbfI0agAGLEH6WkWif+jfTBZ2OEGaPNw+2HPhdnqtfP7gawuDvN72xeN2KtJZKH0vAi3cTGId0rlb0drO0KvYVUGtyyvkYDLDEzJC1gDYl/ewuknqnJYJyxegCc/J3YDiFpCCbQ2kK9464A+os5Y7TGa+RUKF+6kbkuwu+hMRL+aJWJZUjGA==",'
            '"StatusCode": 200'
          '}';
      });
      await client.getAuth();
      HttpRequest req = client.deleteObject('messenger', '1.jpg');
      print(req.asCurl());
      expect(true, equals(true)); 
    });
    test('HttpRequest', () async{
      final req = new HttpRequest('http://aaa.com', 'GET', null, null);
      print(req.asCurl());
    });

  });

}