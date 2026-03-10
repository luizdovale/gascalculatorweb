@echo off
echo ==========================================
echo Atualizando Icones e Gerando Build Web...
echo ==========================================

:: 1. Gerar os ícones novamente (garante que tudo está sincronizado)
call flutter pub run flutter_launcher_icons:main

:: 2. Limpar build anterior
call flutter clean

:: 3. Obter dependências
call flutter pub get

:: 4. Gerar Build para Web
:: IMPORTANTE: Como seu repositório é "gascalculatorweb",
:: o --base-href deve ser "/gascalculatorweb/".
echo Gerando build para Web...
call flutter build web --release --base-href "/gascalculatorweb/"

echo ==========================================
echo Build concluído com sucesso!
echo Os arquivos estão na pasta: build/web/
echo ==========================================
pause
