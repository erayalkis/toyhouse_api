# ACTUAL CODE

# import lib.sh
. lib.sh

[ ! -d "./gui/src-tauri/binaries" ] && mkdir ./gui/src-tauri/binaries

print_info "STARTING BUILD"

build_mac_arm64
build_mac_amd64
build_windows_amd64
build_linux_amd64

print_ok "BUILD PROCESS COMPLETE"

print_info "MOVING FILES TO TAURI BIN"

for path in $MAC_ARM64_BIN $MAC_AMD64_BIN $MS_AMD64_BIN $LINUX_AMD64_BIN; do
  print_info "MOVING $path TO $TAURI_BIN_DIR"
  mv $path $TAURI_BIN_DIR
done

print_ok "MOVED FILES SUCCESSFULLY"
print_ok "PROCESS COMPLETE"