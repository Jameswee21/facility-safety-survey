-- ============================================================
-- 시설안전신고 만족도 조사 - Supabase 스키마
-- Supabase 대시보드 > SQL Editor 에서 이 파일 전체를 실행하세요.
-- ============================================================

create extension if not exists "uuid-ossp";

-- ============================================================
-- 응답 테이블
-- ============================================================
create table if not exists public.satisfaction_responses (
  id             uuid default uuid_generate_v4() primary key,
  rating_overall smallint not null check (rating_overall between 1 and 5),
  rating_speed   smallint not null check (rating_speed between 1 and 5),
  comment        text check (char_length(comment) <= 500),
  created_at     timestamp with time zone default now()
);

comment on column public.satisfaction_responses.rating_overall is '온라인 접수 시행 후 전반적 만족도 (1~5)';
comment on column public.satisfaction_responses.rating_speed   is '업무처리 속도 만족도 (1~5)';
comment on column public.satisfaction_responses.comment        is '개선사항·건의사항 (주관식, 선택)';

-- ============================================================
-- RLS - 익명 사용자는 "등록만" 가능하고 조회는 불가
--   → anon key 가 페이지에 노출되어도 남의 응답을 읽을 수 없습니다.
-- ============================================================
alter table public.satisfaction_responses enable row level security;

drop policy if exists "anon_insert_response" on public.satisfaction_responses;
create policy "anon_insert_response"
  on public.satisfaction_responses
  for insert
  to anon
  with check (
    -- 조사기간(2026-09-01 ~ 2026-09-30) 외 등록 차단
    now() >= timestamptz '2026-09-01 00:00:00+09'
    and now() < timestamptz '2026-10-01 00:00:00+09'
  );

drop policy if exists "authenticated_read_response" on public.satisfaction_responses;
create policy "authenticated_read_response"
  on public.satisfaction_responses
  for select
  to authenticated
  using (true);

-- ============================================================
-- 집계 확인용 뷰 (Supabase SQL Editor 에서 조회)
-- ============================================================
create or replace view public.satisfaction_summary as
select
  count(*)                                        as 응답수,
  round(avg(rating_overall)::numeric, 2)          as 전반만족도_평균,
  round(avg(rating_speed)::numeric, 2)            as 처리속도_평균,
  count(*) filter (where rating_overall >= 4)     as 전반_만족이상,
  count(*) filter (where rating_speed >= 4)       as 속도_만족이상,
  count(*) filter (where comment is not null)     as 의견작성수
from public.satisfaction_responses;
