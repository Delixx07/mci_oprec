# Situs static (TF-IDF dataset misteri) di-serve oleh nginx.
# Image HANYA berisi file static yang sudah di-build di host
# (index.html + data.js). File .env / sumber Python TIDAK masuk image
# (lihat .dockerignore).
#
# Build di host dulu:
#   python build_website.py
# Lalu:
#   docker build -t mci-oprec .
#   docker run -d -p 8080:80 --name mci-oprec mci-oprec
# Situs di http://<ip-vps>:8080

FROM nginx:1.27-alpine

# Konfigurasi nginx ringan untuk SPA/static
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Hanya file yang dibutuhkan situs
COPY index.html /usr/share/nginx/html/index.html
COPY data.js    /usr/share/nginx/html/data.js

EXPOSE 80

# Healthcheck sederhana
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q -O /dev/null http://localhost/ || exit 1
