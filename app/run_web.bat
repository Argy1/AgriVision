@echo off
cd /d "%~dp0"
flutter run -d web-server --web-port 8081 --dart-define=SUPABASE_URL=https://ymfcrxymizwwolikgrhq.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InltZmNyeHltaXp3d29saWtncmhxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAwMjkyNDUsImV4cCI6MjEwNTYwNTI0NX0.TLfuJsQvTLGP3t4MHBC1DLe0I2cStbfEob9GtAFEKNw --dart-define=ML_API_URL=https://ml-service-production-cfd0.up.railway.app
