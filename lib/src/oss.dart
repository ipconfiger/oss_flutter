import 'dart:async';
import 'dart:convert';
import 'utils.dart';

class OSSResponse{
  OSSResponse(){

  }
  int statusCode;
  

}

/// Http Wrpper Class
class HttpRequest{
  HttpRequest(String url, String method, Map param, Map headers){
    this.url = url;
    this.method = method;
    this.param = param;
    this.headers = headers;
  }
  String url = '';
  String method = '';
  Map param;
  Map headers;
  List<int> _fileData;

  set fileData(List<int> bytes){
    this._fileData = bytes;
  }

  List<int> get fileData => this._fileData;

  String get Url{
    var url_params = [];
    var url_base = this.url;
    if ((this.param ?? {}).isNotEmpty){
      this.param.forEach((k, v){
        url_params.add("${k}=${v}");
      });
      final url_string = url_params.join("&");
      if (url_string.length>0){
        url_base = "${url_base}?${url_string}";
      }
    }
    return url_base;
  }

  /// return string of curl command, you can test it in console
  String asCurl({file_path: null}){
    var cmd_base = 'curl ';
    if((this.headers??{}).isNotEmpty){
      this.headers.forEach((k, v){
        cmd_base = "${cmd_base} -H \"${k}:${v}\"";
      });
    }
    if (this.method == 'PUT'){
      cmd_base = "${cmd_base} -T";
    }
    if (this.method == 'POST'){
      cmd_base = "${cmd_base} -X POST";
    }
    if (this.method == 'DELETE'){
      cmd_base = "${cmd_base} -X DELETE";
    }
    if (this._fileData != null){
        cmd_base = "${cmd_base} \"${file_path}\"";
    }
    cmd_base = '${cmd_base} ${this.Url}';
    return cmd_base;  
  }
}

typedef Future<String> GetToken(String);

/// OSS Client
class Client{
  /// init
  /// @param stsRequestUrl type:String Url to get sts token
  /// @param endpointDomain type:String Domain of endpoint
  /// @param getToken type:GetToken function for get sts token
  Client(String stsRequestUrl, String endpointDomain, GetToken getToken){
    this.stsRequestUrl = stsRequestUrl;
    this.endpoint = endpointDomain;
    this.tokenGetter = getToken;
  }
  String stsRequestUrl;
  String endpoint;
  GetToken tokenGetter;

  Auth _auth;
  String _expire;

  bool checkExpire(String expire){
    if(expire == null){
      return false;
    }
    final expireIn = DateTime.parse(expire);
    print(expire);
    if (new DateTime.now().compareTo(expireIn)>0){
      return true;
    }
    return false;
  }

  /// try to get sts auth token
  Future<Client> getAuth() async {
    print('current: ${this._auth} - ${this._expire}');
    if (this.checkExpire(this._expire)){
      return this;
    }else{
      final resp = await this.tokenGetter(this.stsRequestUrl);
      final respMap = jsonDecode(resp);
      this._auth = Auth(respMap['AccessKeyId'], respMap['AccessKeySecret'], respMap['SecurityToken']);
      this._expire = respMap['Expiration'];
      return this;
    }
  }

  bool checkAuthed(){
    if (this._auth != null && this.checkExpire(this._expire)){
      return true;
    }
    return false;
  }

  /// List Buckets
  HttpRequest list_buckets({prefix:'', marker:'', max_keys:100, params:null}) {
      final listParam = {
        'prefix': prefix,
        'marker': marker,
        'max-keys': '${max_keys}'
      };
      if ((params??{}).isNotEmpty){
        if (params.containsKey('tag-key')){
          listParam['tag-key'] = params['tag-key'];
        }
        if (params.containsKey('tag-value')){
          listParam['tag-value'] = params['tag-value'];
        }
      }
      final url = "http://${this.endpoint}";
      HttpRequest req = new HttpRequest(url, 'GET', listParam, {});
      this._auth.signRequest(req, '', '');
      return req;
  }

  /// upload file
  /// @param fileData type:List<int> data of upload file
  /// @param bucketName type:String name of bucket
  /// @param fileKey type:String upload filename
  /// @return type:HttpRequest
  HttpRequest putObject(List<int> fileData, String bucketName, String fileKey) {
    final headers = {
      'content-md5': md5File(fileData),
      'content-type': contentTypeByFilename(fileKey)
    };
    final url = "https://${bucketName}.${this.endpoint}/${fileKey}";
    HttpRequest req = new HttpRequest(url, 'PUT', {}, headers);
    this._auth.signRequest(req, bucketName, fileKey);
    req.fileData = fileData;
    return req;
  }

  /// delete file
  /// @param bucketName type:String name of bucket
  /// @param fileKey type:String upload filename
  /// @return type:HttpRequest
  HttpRequest deleteObject(String bucketName, String fileKey) {
    final url = "https://${bucketName}.${this.endpoint}/${fileKey}";
    final req = HttpRequest(url, 'DELETE', {}, {});
    this._auth.signRequest(req, bucketName, fileKey);
    return req;
  }

}

class Auth {
  Auth(String accessKey, String accessSecret, String secureToken){
    this.accessKey = accessKey;
    this.accessSecret = accessSecret;
    this.secureToken = secureToken;
  }

  String accessKey;
  String accessSecret;
  String secureToken;

  static const _subresource_key_set = ['response-content-type', 'response-content-language',
         'response-cache-control', 'logging', 'response-content-encoding',
         'acl', 'uploadId', 'uploads', 'partNumber', 'group', 'link',
         'delete', 'website', 'location', 'objectInfo', 'objectMeta',
         'response-expires', 'response-content-disposition', 'cors', 'lifecycle',
         'restore', 'qos', 'referer', 'stat', 'bucketInfo', 'append', 'position', 'security-token',
         'live', 'comp', 'status', 'vod', 'startTime', 'endTime', 'x-oss-process',
         'symlink', 'callback', 'callback-var', 'tagging', 'encryption', 'versions',
         'versioning', 'versionId', 'policy'];

  void signRequest(HttpRequest req, String bucket, String key) {
    req.headers['date'] = httpDateNow();
    req.headers['x-oss-security-token'] = this.secureToken;
    final signature = this.make_signature(req, bucket, key);
    req.headers['authorization'] = "OSS ${this.accessKey}:${signature}";
  }

  String make_signature(HttpRequest req, String bucket, String key){
    final string_to_sign = this.get_string_to_sign(req, bucket, key);
    return hmacSign(this.accessSecret, string_to_sign);
  }

  String get_string_to_sign(HttpRequest req, String bucket, String key){
    final resource_string = this.get_resource_string(req, bucket, key);
    final headers_string = this.get_headers_string(req);
    final contentMd5 = req.headers['content-md5'] ?? '';
    final contentType = req.headers['content-type'] ?? '';
    final date = req.headers['date'] ?? '';
    return "${req.method}\n${contentMd5}\n${contentType}\n${date}\n${headers_string}${resource_string}";
  }

  String get_resource_string(HttpRequest req, String bucket, String key){
    if((bucket ?? '').isEmpty){
      return "/";
    }else{
      final substring = this.get_subresource_string(req.param);
      return "/${bucket}/${key}${substring}";
    }
  }

  String get_headers_string(HttpRequest req){
    var canon_headers = [];
    for(final key in req.headers.keys){
      if (key.toLowerCase().startsWith('x-oss-')){
        canon_headers.add(key.toLowerCase());
      }
    }
    canon_headers.sort((s1, s2){
      return s1.compareTo(s2);
    });
    if (canon_headers.length>0){
      final header_strings = canon_headers.map((key){
        final v = req.headers[key];
        return "${key}:${v}";
      }).join("\n");
      return "${header_strings}\n";
    }else{
      return '';
    }
  }

  String get_subresource_string(Map params){
    if ((params ?? {}).isNotEmpty){
      return '';
    }
    var subresource_params = [];
    for(final key in params.keys){
      if (_subresource_key_set.contains(key)){
        subresource_params.add([key, params[key]]);
      }
    }
    subresource_params.sort((item1, item2){
        return item1[0].compareTo(item2[0]);
    });
    if (subresource_params.length > 0){
      final seqs = subresource_params.map((arr){
        final k = arr[0];
        final v = arr[1];
        if (v!=null && v!=''){
          return "${k}=${v}";
        }else{
          return k;
        }
      });
      final paramstring = seqs.join('&');
      return "?${paramstring}";
    }else{
      return '';
    }
  }

}