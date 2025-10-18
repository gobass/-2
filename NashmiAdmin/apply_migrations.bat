@echo off
echo ========================================
echo Nashmi Admin Database Migration Script
echo ========================================
echo.
echo This script will help you apply the database migrations.
echo Since psql is not available, please follow these steps:
echo.
echo 1. Open your Supabase dashboard
echo 2. Go to SQL Editor
echo 3. Copy and paste the following SQL content:
echo.
echo --- MIGRATION SQL START ---
type merged_migration.sql
echo --- MIGRATION SQL END ---
echo.
echo 4. Click 'Run' to execute the migration
echo 5. After successful execution, restart your Supabase instance if needed
echo.
echo Press any key to continue...
pause > nul
