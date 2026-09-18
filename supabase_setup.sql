-- ==============================================================
-- รันสคริปต์นี้ใน Supabase: เมนู "SQL Editor" -> New query -> วางแล้วกด Run
-- ทำครั้งเดียวตอนตั้งค่าโปรเจกต์ครั้งแรก
-- ==============================================================

create extension if not exists vector;

create table if not exists documents (
    id bigserial primary key,
    content text not null,
    metadata jsonb not null,       -- เก็บ {"source": "ชื่อไฟล์.pdf", "page": 12}
    embedding vector(768)          -- 768 มิติ ตามโมเดล gemini-embedding-001 ของ Google
);

create table if not exists pdf_files (
    id bigserial primary key,
    filename text unique not null,
    storage_path text not null,
    uploaded_at timestamptz default now(),
    page_count int,
    chunk_count int
);

-- ฟังก์ชันค้นหาชิ้นเนื้อหาที่ใกล้เคียงกับคำถามมากที่สุด (ใช้ cosine similarity)
-- filter_source: ถ้าระบุชื่อไฟล์ จะค้นเฉพาะไฟล์นั้น (ไม่ปนไฟล์อื่น) ถ้าเป็น null จะค้นทุกไฟล์
create or replace function match_documents (
  query_embedding vector(768),
  match_count int default 5,
  filter_source text default null
)
returns table (
  id bigint,
  content text,
  metadata jsonb,
  similarity float
)
language sql stable
as $$
  select
    documents.id,
    documents.content,
    documents.metadata,
    1 - (documents.embedding <=> query_embedding) as similarity
  from documents
  where filter_source is null or documents.metadata->>'source' = filter_source
  order by documents.embedding <=> query_embedding
  limit match_count;
$$;

create index if not exists documents_embedding_idx
  on documents using ivfflat (embedding vector_cosine_ops)
  with (lists = 100);
