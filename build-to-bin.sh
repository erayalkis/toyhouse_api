
BLUE='\033[0;34m'
L_BLUE='\033[1;34m'
GREEN='\033[0;32m'
L_GREEN='\033[1;32m'
RED='\033[0;31m'
L_RED='\033[1;31m'
NC='\033[0m'

MAC_ARM64_BIN="main-aarch64-apple-darwin"
MAC_AMD64_BIN="main-x86_64-apple-darwin"
MS_AMD64_BIN="main-x86_64-pc-windows-msvc.exe"
LINUX_AMD64_BIN="main-x86_64-unknown-linux-gnu"

TAURI_BIN_DIR="./gui/src-tauri/bin"

[ ! -d "./gui/src-tauri/bin" ] && mkdir ./gui/src-tauri/bin

printf "${BLUE}[INFO]${NC} STARTING BUILD\n"

GOOS="darwin"  GOARCH="arm64" go build -o $MAC_ARM64_BIN       main.go
GOOS="darwin"  GOARCH="amd64" go build -o $MAC_AMD64_BIN       main.go
GOOS="windows" GOARCH="amd64" go build -o $MS_AMD64_BIN        main.go
GOOS="linux"   GOARCH="amd64" go build -o $LINUX_AMD64_BIN     main.go

printf "${GREEN}[OK]${NC} BUILD PROCESS COMPLETE\n"

printf "${BLUE}[INFO]${NC} MOVING FILES TO TAURI BIN\n"

mv $MAC_ARM64_BIN     $TAURI_BIN_DIR
mv $MAC_AMD64_BIN     $TAURI_BIN_DIR
mv $MS_AMD64_BIN      $TAURI_BIN_DIR
mv $LINUX_AMD64_BIN   $TAURI_BIN_DIR