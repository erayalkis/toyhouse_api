
go build main.go

mkdir ./gui/src-tauri/bin
cp ./main ./gui/src-tauri/bin/main
mv ./gui/src-tauri/bin/main ./gui/src-tauri/bin/main-aarch64-apple-darwin
cp ./main ./gui/src-tauri/bin/main
mv ./gui/src-tauri/bin/main ./gui/src-tauri/bin/main-x86_64-apple-darwin
cp ./main ./gui/src-tauri/bin/main
mv ./gui/src-tauri/bin/main ./gui/src-tauri/bin/main-x86_64-unknown-linux-gnu
cp ./main ./gui/src-tauri/bin/main
