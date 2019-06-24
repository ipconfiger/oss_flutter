# oss_flutter
pure dart oss client for flutter (only support STS authentication)

Only generate signature and http request wrapper instance

your have to implement 2 things

1. request to update STS token
2. request to do real http request

### Usage

#### 1. Install

    dependencies:
        oss_flutter: ^0.1.0

#### 2. Initialization

    import 'package:oss_flutter/oss_flutter.dart';

    final client = Client('url to fetch sts token', 'oss bucket domain', (url) async{
        // use your favorite http lib to fetch sts token
        // return as 
        //{
        //    "AccessKeyId": "STS.NJt3c8tHjMzwzPvxoB6QHFwLY", 
        //    "AccessKeySecret": "2momjH1gfJ9RFA57cPwTA1of6Pr29qijGGkeXsVyoSqt", 
        //   "Expiration": "2019-06-23T16:40:01Z", 
        //    "SecurityToken": "CAIS9gF1q6Ft5B2yfSjIr4nBeNmMmZdL+riceHbHnG8XOt5kqbLnuzz2IH9OeHhqB+kWsPkyn2FW7fwalrh+W4NIX0rNaY5t9ZlN9wqkbtJUNnF0PflW5qe+EE2/VjTZvqaLEcibIfrZfvCyESOm8gZ43br9cxi7QlWhKufnoJV7b9MRLGLaBHg8c7UwHAZ5r9IAPnb8LOukNgWQ4lDdF011oAFx+wgdgOadupDGtUOC0QCilrZM99yre8WeApMybMcvYbCcx/drc6fN6ilU5iVR+b1+5K4+omid4oDHXQABvUjbaLuKqYc3NmF+fbMzEKVUczQjVFHbfI0agAEqTKBFvjnmklHx9Gg8O9Hw4V0oIhmodRXGMT0NxFSBa+GghJOrfjNiNl60P8Z72OOsww2fXsubwkz7u9dAifyb8oZ0z1o60NRCBXOZxSFxOHDpljq+wByr4yE2n5qIkjeqSkJrMKnhBxtXKGEbyIU8WdJXjOkQxWaxIEXlFgfE1A==", 
        //    "StatusCode": 200
        //}
    });

#### 3 Access OSS Services

    final req = client.list_buckets() // return wrapper
    // make real http request with req use your favorite http lib

