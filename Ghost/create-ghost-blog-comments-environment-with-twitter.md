# Ghost 블로그에 Twitter 댓글 활용하기

* 오픈소스 블로그 플랫폼 Ghost에는 댓글 기능 부재
* Facebook Comments Plugins 사용시 네트워크 속도 문제로 컨텐츠 로드와 별개 스크립트 로드 후 렌더링 하는 시간이 필요해서 페이지 전체 로드 속데 느리게 만드는 문제 발생
* Twitter 의 [Web Intent](https://developer.twitter.com/en/docs/twitter-for-websites/tweet-button/guides/web-intent) 를 사용하여 Ghost 블로그 내 댓글 기능 추가

## Twitter Web Intent URL

https://twitter.com/intent/tweet

에 `in_reply_to` 파라미터를 사용하여 블로그에 유일한 prarent twttierId 를 이용하여 댓글처럼 사용할 수 있음

## Ghost 템플릿에 Twitter 댓글 작성하는 버튼추가

`$GHOST_HOME/content/themes/casper/post.hbs` 파일에 버튼이 위치할 곳에 다음 코드 추가

```html
<a href="" id="twitter-comments" style="display:none;">Twitter 로 댓글 남기기</a>
```

## Ghost 전역 Code Injection 추가

```javascript
<script>
    var twitterIdElement = document.getElementById("twitter-id")
    if(twitterIdElement) {
        var twitterId = twitterIdElement.getAttribute("data-twitter-id");
		var twitterComments = document.getElementById("twitter-comments");
        if(twitterComments){
	        twitterComments.setAttribute("style", "display:block;");
    	    twitterComments.setAttribute("href", "https://twitter.com/intent/tweet?in_reply_to="+twitterId);        
        }
    }  
</script>
```

## 블로그 글 포스팅 후 Twitter 로 글 공유 후 원글 twitterId 획득


블로그 글을 twitter 로 먼저 공유한 다음 twitter의 글 아이디 획득하여 다음 내용으로 Post 작성하는 **Code Injection** 내용에 다음 코드 추가

```html
<div id="twitter-id" data-twitter-id="트위터 원글 아이디"></div>
```