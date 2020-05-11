# http-proxy-middleware 패키지에서 multipart/form-data 지원

[http-proxy-middleware](https://github.com/chimurai/http-proxy-middleware) 패키지는 기본적으로 application/json 요청만 처리하기 때문에 form 전송과 파일업로드를 지원하지 않는다. 그래서 `onProxyReq` 옵션을 이용하여 proxyReq 요청을 변경해서 처리하도록 해야한다. 

request의 header 정보 중 **Content-Type** 을 확인하여 `application\/x-www-form-urlencoded` 일 경우와 `multipart/form-data` 일 경우 proxyReq 를 rewrite 시켜준다.



## Reference 
* [Node.js TypeScript: sending HTTP requests](https://wanago.io/2019/03/18/node-js-typescript-6-sending-http-requests-understanding-multipart-form-data/)
* https://stackoverflow.com/questions/58451402/nodejs-edit-and-proxy-a-multipart-form-data-request
* https://stackoverflow.com/questions/43913650/how-to-send-a-buffer-in-form-data-to-signserver
* https://github.com/http-party/node-http-proxy
* https://stackoverflow.com/questions/4238809/example-of-multipart-form-data
* http://qnimate.com/stream-file-uploads-to-storage-server-in-node-js/
* https://stackoverflow.com/questions/25455475/generating-http-multipart-body-for-file-upload-in-javascript
* https://github.com/freesoftwarefactory/parse-multipart/blob/master/multipart.js
* https://www.npmjs.com/package/form-data
* [Multipart Entity 에서 파일 업로드 간략 정리](https://csjung.tistory.com/199)
* https://stackoverflow.com/questions/46959556/byte-size-of-buffer-javascript-node
* [Multipart-POST Request Using Node.js](https://gist.github.com/tanaikech/40c9284e91d209356395b43022ffc5cc)
* https://stackoverflow.com/questions/24306335/413-request-entity-too-large-file-upload-issue
* https://serverfault.com/questions/768693/nginx-how-to-completely-disable-request-body-buffering