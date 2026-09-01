# 시설안전신고 만족도 조사 페이지

QR 코드로 접속 → 만족도 조사(3문항) 응답 → 전송하면 Supabase에 저장 → 아래 시설안전신고(네이버폼) 링크로 이동.

```
의견조사/
├── index.html            ← GitHub Pages에 올릴 페이지 (이 파일 하나면 동작)
├── supabase-schema.sql   ← Supabase SQL Editor에서 1회 실행
└── README.md
```

## 설문 구성

| # | 문항 | 형식 | 필수 |
|---|------|------|------|
| 01 | 전화 접수만 가능했던 이전과 비교해, 온라인 접수 시행 후 전반적 만족도 | 5점 척도 | 필수 |
| 02 | 신고 접수부터 조치 완료까지 업무처리 속도 만족도 | 5점 척도 | 필수 |
| 03 | 개선이 필요한 점이나 건의사항 | 주관식(500자) | 선택 |

조사기간 **2026. 9. 1. ~ 9. 30.** — 기간이 지나면 페이지의 폼이 자동으로 잠기고, Supabase 정책에서도 기간 외 등록을 차단합니다.

---

## 설치 순서

### 1. Supabase — 완료됨

- 프로젝트: `ndhicnagwfsulgdehbqg`
- `supabase-schema.sql` 실행 완료 (테이블 `satisfaction_responses` + RLS + 집계 뷰)

### 2. index.html 접속 정보 — 입력 완료

`index.html` 하단 `<script>` 안에 아래 값이 이미 들어가 있습니다.

```js
var SUPABASE_URL = "https://ndhicnagwfsulgdehbqg.supabase.co";
var SUPABASE_ANON_KEY = "eyJhbGciOi...";   // anon public 키
```

> anon 키는 페이지에 노출되어도 되는 공개 키입니다. RLS 정책상 **등록(insert)만** 가능하고 **조회(select)는 차단**되어 있어, 다른 사람의 응답 내용을 읽을 수 없습니다. 실제로 확인한 결과 등록은 `201`, 조회는 빈 결과였습니다. `service_role` 키는 절대 넣지 마세요.
>
> 프로젝트를 바꾸실 때는 Supabase 대시보드 주소 `.../project/<이 부분>` 이 프로젝트 ID이고, Project URL은 `https://<프로젝트 ID>.supabase.co` 입니다. 키는 **Project Settings → API**(최근 화면은 **API Keys**) 에서 확인합니다.

### 3. GitHub Pages 배포

```bash
git init
git add index.html README.md supabase-schema.sql
git commit -m "시설안전신고 만족도 조사 페이지"
git branch -M main
git remote add origin https://github.com/<사용자명>/<저장소명>.git
git push -u origin main
```

GitHub 저장소 → **Settings → Pages** → Source: `Deploy from a branch` → Branch: `main` / `/ (root)` → Save.

1~2분 뒤 아래 주소로 열립니다.

```
https://<사용자명>.github.io/<저장소명>/
```

### 4. QR 코드 생성

위 주소로 QR을 만들어 게시합니다. (https://qr.io, https://www.qrcode-monkey.com 등)

---

## 결과 확인

Supabase 대시보드에서 봅니다. anon 키로는 조회가 안 되므로 로그인한 대시보드에서만 열람됩니다.

- 개별 응답: **Table Editor → `satisfaction_responses`**
- 집계: **SQL Editor** 에서

```sql
select * from public.satisfaction_summary;
```

- 엑셀로 내리기: Table Editor 우측 상단 **Export → CSV**

---

## 동작 메모

- 응답은 **완전 익명**입니다. 이름·부서·IP 등 식별 정보를 수집하지 않습니다.
- 한 번 응답한 기기는 브라우저에 표시가 남아 다시 열면 "응답 완료" 화면이 뜹니다. 중복 제출을 막는 장치는 아니며, **다시 응답하기**로 재응답할 수 있습니다.
- 전송이 실패하면 입력값을 유지한 채 "다시 전송하기"가 표시됩니다.
- 시설안전신고 바로가기: `https://naver.me/xdMo2cwA`
