# VARIABLE AND FUNCTION DECLARATIONS

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

TAURI_BIN_DIR="./gui/src-tauri/binaries"

process_done=false
process_done() {
  $process_done
}
sp='/-\|'
sc=0
spin() {
   printf "\r${sp:sc++:1} $1"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

print_info() {
  printf "${BLUE}[INFO]${NC} $1\n"
}

print_ok() {
  printf "${GREEN}[OK]${NC} $1\n"
}

build_binary_for() {
  print_info "BUILDING $1-$2"
  until process_done; do
    spin "Building binary..."
    GOOS=$1  GOARCH=$2 go build -o $3 main.go
    process_done=true
  done
  endspin
  process_done=false
}

build_mac_arm64() {
  build_binary_for "darwin"  "arm64" $MAC_ARM64_BIN
}
build_mac_amd64() {
  build_binary_for "darwin"  "amd64" $MAC_AMD64_BIN
}

build_windows_amd64() {
  build_binary_for "windows" "amd64" $MS_AMD64_BIN
}

build_linux_amd64() {
  build_binary_for "linux"   "amd64" $LINUX_AMD64_BIN
}
