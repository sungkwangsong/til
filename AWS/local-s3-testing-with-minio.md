# MinIO로 S3 로컬 테스트 환경 구성하기

## MinIO란?

MinIO는 AWS S3 API와 완벽하게 호환되는 오픈소스 객체 스토리지(Object Storage) 서버다. Go 언어로 작성되어 있어 단일 바이너리로 실행되고, Docker 하나면 로컬에서 바로 띄울 수 있다.

핵심은 **S3 호환 API**다. AWS SDK나 CLI에서 엔드포인트만 `localhost:9000`으로 바꾸면 실제 AWS S3와 동일하게 동작한다. 덕분에 AWS 계정이나 비용 걱정 없이 개발/테스트 환경을 구성할 수 있다.

![MinIO S3 API 호환 구조](https://cdn.prod.website-files.com/681c8426519d8db8f867c1e8/69428af7954bab4982fa35e8_s3-api.avif)
*출처: [MinIO S3 API Compatibility](https://www.min.io/product/aistor/s3-api) — 동일한 S3 API로 클라우드(AWS)와 로컬(MinIO) 모두 연결 가능*

```
[AWS S3 사용 시]           [MinIO 사용 시]

Application               Application
    │                          │
    │ AWS SDK (HTTPS)           │ AWS SDK (HTTP)
    ▼                          ▼
AWS S3 (us-east-1)        MinIO (localhost:9000)
    │                          │
[리전 데이터센터]           [로컬 디스크]
```

코드 변경 없이 `endpoint` URL만 교체하면 되기 때문에, 개발 단계에서는 MinIO를, 프로덕션에서는 실제 S3를 사용하는 구성이 가능하다.

## MinIO 아키텍처

MinIO는 객체 스토리지의 핵심 개념인 **버킷(Bucket)**과 **오브젝트(Object)** 구조를 그대로 따른다.

```
MinIO 서버 (localhost:9000)
│
├── Bucket A
│   ├── profile.png
│   ├── uploads/
│   │   └── document.pdf
│   └── ...
│
└── Bucket B
    └── ...

로컬 파일시스템 매핑:
./minio-data/
├── Bucket A/
│   ├── profile.png
│   └── uploads/
│       └── document.pdf
└── Bucket B/
```

버킷은 파일시스템의 루트 디렉토리처럼 동작하고, 오브젝트는 그 안의 파일이다. MinIO는 이 구조를 로컬 파일시스템 위에 그대로 매핑해서 저장한다.

## Docker로 MinIO 실행

```bash
docker run -d \
  --name minio \
  -p 9000:9000 \
  -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  -v $(pwd)/minio-data:/data \
  quay.io/minio/minio server /data --console-address ":9001"
```

| 포트 | 용도 |
|------|------|
| 9000 | S3 API 엔드포인트 |
| 9001 | 웹 콘솔 (브라우저) |

```
포트 역할:

  Browser  ──→  :9001  ──→  MinIO 웹 콘솔 (GUI)
  App/SDK  ──→  :9000  ──→  S3 API (AWS SDK 호환)
```

컨테이너가 뜨면 `http://localhost:9001`에서 웹 콘솔에 접속할 수 있다. 초기 계정은 `minioadmin` / `minioadmin`이다.

웹 콘솔에서는 버킷 생성, 파일 업로드/다운로드, 접근 정책 설정 등을 GUI로 다룰 수 있다.

![MinIO 웹 콘솔](https://cdn.prod.website-files.com/682ce31dd525b48fec3d97c8/698c95ea974a746c999aa0d0_696fa3c419b73ab22f0ee69d_image-53.png)
*출처: [New MinIO Console](https://min.io/blog/new-minio-console) — 웹 콘솔 대시보드*

## Node.js (AWS SDK v3)로 연결

AWS SDK v3를 그대로 사용한다. 차이는 `endpoint`와 `forcePathStyle` 두 옵션뿐이다.

```bash
npm install @aws-sdk/client-s3
```

```javascript
import {
  S3Client,
  CreateBucketCommand,
  PutObjectCommand,
  GetObjectCommand,
  ListObjectsV2Command,
  DeleteObjectCommand,
} from "@aws-sdk/client-s3";

const s3 = new S3Client({
  endpoint: "http://localhost:9000",
  region: "us-east-1",
  credentials: {
    accessKeyId: "minioadmin",
    secretAccessKey: "minioadmin",
  },
  forcePathStyle: true, // MinIO 사용 시 필수
});
```

`forcePathStyle: true`가 핵심이다. AWS S3는 기본적으로 `bucket-name.s3.amazonaws.com` 형식의 가상 호스팅 URL을 쓰는데, MinIO는 이 방식을 지원하지 않는다. 이 옵션을 켜면 `localhost:9000/bucket-name` 형식의 경로 기반 URL로 전환된다.

```
가상 호스팅 방식 (AWS S3 기본):
  https://my-bucket.s3.amazonaws.com/object-key

경로 기반 방식 (forcePathStyle: true):
  http://localhost:9000/my-bucket/object-key
                        └─────────────────┘
                         MinIO가 인식하는 형식
```

### 기본 CRUD

```javascript
// 버킷 생성
await s3.send(new CreateBucketCommand({ Bucket: "my-bucket" }));

// 파일 업로드
await s3.send(new PutObjectCommand({
  Bucket: "my-bucket",
  Key: "hello.txt",
  Body: "Hello, MinIO!",
  ContentType: "text/plain",
}));

// 파일 목록 조회
const listResult = await s3.send(new ListObjectsV2Command({
  Bucket: "my-bucket",
}));
listResult.Contents?.forEach(obj => console.log(obj.Key));

// 파일 다운로드
const getResult = await s3.send(new GetObjectCommand({
  Bucket: "my-bucket",
  Key: "hello.txt",
}));
const body = await getResult.Body?.transformToString();
console.log(body); // "Hello, MinIO!"

// 파일 삭제
await s3.send(new DeleteObjectCommand({
  Bucket: "my-bucket",
  Key: "hello.txt",
}));
```

## 테스트 흐름

MinIO를 활용한 통합 테스트의 전체 흐름은 다음과 같다.

```
통합 테스트 흐름:

  ┌─────────────────────────────────────────┐
  │              Test Suite                 │
  │                                         │
  │  beforeAll ──→ MinIO 컨테이너 시작       │
  │             ──→ 테스트용 버킷 생성       │
  │                      │                  │
  │  test ──→ 앱 코드 실행 (S3 업로드 등)   │
  │        ──→ MinIO에서 결과 검증           │
  │                      │                  │
  │  afterAll ──→ 버킷/데이터 정리           │
  │            ──→ MinIO 컨테이너 종료       │
  └─────────────────────────────────────────┘
```

[testcontainers](https://testcontainers.com/)를 사용하면 테스트마다 MinIO 컨테이너를 자동으로 올리고 내릴 수 있다.

```bash
npm install testcontainers @aws-sdk/client-s3
```

```javascript
import { GenericContainer } from "testcontainers";
import {
  S3Client,
  CreateBucketCommand,
  PutObjectCommand,
  GetObjectCommand,
} from "@aws-sdk/client-s3";

let container;
let s3;

beforeAll(async () => {
  container = await new GenericContainer("quay.io/minio/minio")
    .withExposedPorts(9000)
    .withEnvironment({
      MINIO_ROOT_USER: "minioadmin",
      MINIO_ROOT_PASSWORD: "minioadmin",
    })
    .withCommand(["server", "/data"])
    .start();

  const port = container.getMappedPort(9000);

  s3 = new S3Client({
    endpoint: `http://localhost:${port}`,
    region: "us-east-1",
    credentials: { accessKeyId: "minioadmin", secretAccessKey: "minioadmin" },
    forcePathStyle: true,
  });

  await s3.send(new CreateBucketCommand({ Bucket: "test-bucket" }));
}, 30_000);

afterAll(async () => {
  await container.stop();
});

test("파일 업로드 후 다운로드", async () => {
  await s3.send(new PutObjectCommand({
    Bucket: "test-bucket",
    Key: "test.txt",
    Body: "hello",
  }));

  const result = await s3.send(new GetObjectCommand({
    Bucket: "test-bucket",
    Key: "test.txt",
  }));
  const content = await result.Body?.transformToString();
  expect(content).toBe("hello");
});
```

## docker-compose로 구성

로컬 개발 환경에 MinIO를 포함시킬 때는 docker-compose가 편하다.

```yaml
services:
  minio:
    image: quay.io/minio/minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio-data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  minio-data:
```

앱 서비스와 함께 구성할 때는 `depends_on`으로 MinIO가 먼저 준비되도록 설정한다.

```yaml
services:
  app:
    build: .
    depends_on:
      minio:
        condition: service_healthy
    environment:
      S3_ENDPOINT: http://minio:9000
      S3_ACCESS_KEY: minioadmin
      S3_SECRET_KEY: minioadmin

  minio:
    image: quay.io/minio/minio
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      MINIO_ROOT_USER: minioadmin
      MINIO_ROOT_PASSWORD: minioadmin
    volumes:
      - minio-data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 10s
      timeout: 5s
      retries: 3

volumes:
  minio-data:
```

`S3_ENDPOINT`를 환경변수로 주입하면 코드는 건드리지 않고 로컬(MinIO)과 프로덕션(AWS S3) 환경을 전환할 수 있다.

```
환경별 전환 구조:

  개발/테스트:  S3_ENDPOINT=http://minio:9000    ──→ MinIO (로컬)
  프로덕션:     S3_ENDPOINT=https://s3.amazonaws.com ──→ AWS S3
                                    ↑
                            코드 변경 없이 env만 교체
```
