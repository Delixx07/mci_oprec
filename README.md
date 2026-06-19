# Dataset Misteri — TF-IDF Oprec

Situs static untuk membagikan dataset teka-teki. Peserta memasukkan NRP,
lalu mengunduh file `.txt` yang **urutannya diacak per-NRP** namun hasil
**TF-IDF-nya tetap sama**. NRP yang diterima mendapat kata kunci "diterima",
selain itu mendapat versi "ditolak".

## File

| File | Keterangan |
|---|---|
| `index.html` | Situs (UI + logika hash & shuffle). Ini yang di-deploy. |
| `data.js` | Korpus + hash NRP, hasil build. Ikut di-deploy. |
| `generate_datasets.py` | Membuat korpus master (`corpus_*.txt`). |
| `build_website.py` | Build `data.js` + suntik salt ke `index.html`. |
| `solusi_referensi.py` | Kunci jawaban (cek TF-IDF). |
| `verifikasi_e2e.js` | Uji end-to-end (Node). |
| `.env` | **RAHASIA** — kunci + daftar NRP. **Tidak di-commit.** |

## Cara build ulang (jika ganti NRP / korpus / kunci)

```bash
# 1. (opsional) generate korpus baru
python generate_datasets.py

# 2. edit .env: NRP_SECRET_KEY, NRP_DITERIMA (pisah koma)

# 3. build -> data.js + suntik salt ke index.html
python build_website.py

# 4. verifikasi
node verifikasi_e2e.js
```

## Deploy

### A. Docker / VPS (disarankan untuk VPS)

Build file static dulu di host (butuh `.env`), lalu jalankan container.
Image **hanya** berisi `index.html` + `data.js` — `.env` & sumber tidak ikut
(lihat `.dockerignore`).

```bash
python build_website.py          # hasilkan data.js + suntik salt
docker compose up -d --build     # serve via nginx
# situs di http://<ip-vps>:8080  (ubah port di docker-compose.yml)
```

Tanpa compose:
```bash
docker build -t mci-oprec .
docker run -d -p 8080:80 --restart unless-stopped --name mci-oprec mci-oprec
```

> Update konten: edit `.env` → `python build_website.py` → `docker compose up -d --build`.

### B. GitHub Pages (alternatif gratis)

Aktifkan: **Settings → Pages → Branch: `main` / root → Save.**
Situs live di `https://<user>.github.io/<repo>/`.

## ⚠️ Keamanan

- `.env` **tidak pernah** di-commit (lihat `.gitignore`).
- `data.js` hanya berisi **hash PBKDF2** NRP — bukan NRP asli.
- Karena situs static, salt ikut ke browser: ini **obfuscation kuat**
  (PBKDF2 200k iterasi), bukan irreversible mutlak. Untuk rahasia penuh,
  butuh backend.
