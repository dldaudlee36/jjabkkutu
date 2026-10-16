@echo off
chcp 65001 > nul
cd /d "%~dp0"
echo ========================================================
echo   끄투 LITE - GitHub / Vercel 자동 배포 푸시
echo ========================================================
echo.
git push origin main
echo.
if %ERRORLEVEL% EQU 0 (
    echo ========================================================
    echo   성공적으로 GitHub에 반영되었습니다!
    echo   Vercel(https://kkutu-lite.vercel.app)에 1~2분 내 자동 반영됩니다.
    echo ========================================================
) else (
    echo   푸시 중 오류가 발생했습니다. 브라우저 인증 또는 토큰을 확인해 주세요.
)
pause
