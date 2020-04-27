# GitHub Action 을 이용하여 TIL README 파일 자동생성


## GitHub Marketplace 에서 GitHub Action 설치

* TIL의 README를 자동생성하기 위한 GitHub Action 검색
* [TIL Auto-Format README](https://github.com/marketplace/actions/til-auto-format-readme) 사용
* master 브랜치에 `.github/workflows/build.yml` 에 다음 내용 저장

```yaml
name: Build README
on:
  push:
    branches:
    - master
    paths-ignore:
    - README.md
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - name: Check out repo
      uses: actions/checkout@v2
      with:
        # necessary for github-action-til-autoformat-readme
        fetch-depth: 0
    - name: Autoformat README
      uses: cflynn07/github-action-til-autoformat-readme@1.1.0
      with:
        description: |
          A collection of concrete writeups of small things I learn daily while working
          and researching. My goal is to work in public. I was inspired to start this
          repository after reading Simon Wilson's [hacker new post][1], and he was
          apparently inspired by Josh Branchaud's [TIL collection][2].
        footer: |
          [1]: https://simonwillison.net/2020/Apr/20/self-rewriting-readme/
          [2]: https://github.com/jbranchaud/til
        list_most_recent: 2 # optional, lists most recent TILS below description
```