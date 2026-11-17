# Image LOKAL untuk web (Next.js 16). Produksi di Vercel TIDAK memakai berkas ini.
# Build context = ./web  (lihat docker-compose.yml di root repo)
#
# NEXT_PUBLIC_* di-inline saat `next build`, jadi harus diberikan sebagai build arg
# (docker-compose.yml meneruskannya dari .env). Ubah nilainya => bangun ulang image.
FROM node:22-bookworm-slim

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

ARG NEXT_PUBLIC_SUPABASE_URL
ARG NEXT_PUBLIC_SUPABASE_ANON_KEY
ARG NEXT_PUBLIC_ML_API_URL
ENV NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL \
    NEXT_PUBLIC_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_ANON_KEY \
    NEXT_PUBLIC_ML_API_URL=$NEXT_PUBLIC_ML_API_URL

RUN npm run build

ENV NODE_ENV=production
EXPOSE 3000
CMD ["npm", "run", "start", "--", "-H", "0.0.0.0", "-p", "3000"]
