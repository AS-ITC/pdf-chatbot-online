# AI Chatbot ออนไลน์ ตอบคำถามจากคู่มือ PDF (มี Login + คลังไฟล์ + สิทธิ์ Admin)

เว็บแอปแชทบอทถามตอบจากคู่มือ PDF ที่แนบเข้าไป — เปิดผ่านลิงก์เดียวใช้ได้ทุกเครื่อง
มีระบบ login แยก Admin/User และหน้าจัดการคลังไฟล์ในตัว

## สถาปัตยกรรม
- **Hosting**: Streamlit Community Cloud
- **ฐานข้อมูล + ไฟล์**: Supabase (Postgres + pgvector สำหรับค้นหา, Storage สำหรับไฟล์ต้นฉบับ)
- **AI**: Google Gemini API — ใช้ทั้ง embedding (ค้นหา) และตอบคำถาม รองรับหลาย API key สลับอัตโนมัติ

## ไฟล์ในโปรเจกต์
- `app.py` — หน้าเว็บหลัก (sidebar, แชท, จัดการคลังไฟล์)
- `auth.py` — ระบบ login
- `theme.py` — ธีมสี/CSS
- `db.py` — เชื่อม Supabase
- `gemini_embed.py` — embedding ผ่าน Gemini (รองรับหลาย API key)
- `llm.py` — ตอบคำถามผ่าน Gemini
- `ingest_utils.py` — แตกไฟล์ PDF และแบ่งชิ้นเนื้อหา
- `supabase_setup.sql` — SQL ตั้งค่าฐานข้อมูลครั้งแรก
- `.streamlit/config.toml` — บังคับธีม light
- `.streamlit/secrets.toml.example` — ตัวอย่างการตั้งค่า secrets

## ตั้งค่าครั้งแรก

1. **Supabase**: สร้างโปรเจกต์ใหม่ → SQL Editor รัน `supabase_setup.sql` → Storage สร้าง bucket ชื่อ `pdfs` (private)
2. **Gemini API key**: https://aistudio.google.com/apikey (สร้างได้หลาย key ถ้าอยากมีตัวสำรอง)
3. **GitHub**: อัพโค้ดทั้งหมดขึ้น repo (ยกเว้น `.streamlit/secrets.toml` ตัวจริง)
4. **Streamlit Cloud**: https://share.streamlit.io → New app → เลือก repo → main file `app.py`
5. **Secrets**: ใส่ตามฟอร์แมตใน `.streamlit/secrets.toml.example`

## การใช้งาน
- **Admin**: กด "＋ แนบคู่มือเพิ่ม" อัพโหลด PDF ได้เลย จัดการ/ลบไฟล์ได้ที่ "🗂️ จัดการคลังไฟล์"
- **ทุกคน**: เลือกคุย "💬 คำถามทั่วไป" (ค้นทุกคู่มือ) หรือเลือกคู่มือเฉพาะเล่มจากเมนูซ้าย

## หมายเหตุ
- ถ้าเจอ error โควต้าเต็ม (429 RESOURCE_EXHAUSTED) เป็นโควต้ารายวังฟรีของ Gemini (1,000 request/วัน/model) รอรีเซ็ตพรุ่งนี้ หรือเพิ่ม API key สำรองใน secrets (`api_keys = [...]`)
- ไฟล์ PDF สแกน/รูปภาพจะดึงข้อความไม่ได้ ต้องเพิ่ม OCR
