// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::{fs, path::PathBuf};

use futures::StreamExt;

// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
async fn download_character(
    id: String,
    links: Vec<String>,
    credits: String,
    metadata: String,
    logs: Option<String>,
) -> PathBuf {
    let mut download_path = tauri::api::path::download_dir().unwrap();
    let folder_name = format!("{}-gallery", id);
    download_path.push(folder_name);

    fs::create_dir_all(&download_path).unwrap();

    download_charcter_gallery(&id, links).await;
    write_character_credits(&id, credits);
    write_character_metadata(&id, metadata);

    if logs.is_some() {
        write_character_logs(&id, logs.unwrap());
    }

    return download_path;
}

async fn download_charcter_gallery(id: &String, links: Vec<String>) {
    let iter = links.into_iter();

    for (idx, mut link) in iter.enumerate() {
        let mut download_path = tauri::api::path::download_dir().unwrap();
        let folder_name = format!("{}-gallery", id);
        download_path.push(folder_name);

        tokio::spawn(async move {
            let qmark_index = link.chars().position(|c| c == '?');
            if qmark_index.is_some() {
                link = link[0..qmark_index.unwrap()].to_string();
            }

            let ext = link.split(".").last();
            if ext.is_none() {
                panic!("Could not find extension in URL, something is very wrong!");
            }

            let filename = format!("{}.{}", idx, ext.unwrap());
            let full_path = format!("{}/{}", download_path.display(), filename);

            let mut tmp_file = tokio::fs::File::create(full_path).await.unwrap();
            let mut byte_stream = reqwest::get(link).await.unwrap().bytes_stream();

            while let Some(item) = byte_stream.next().await {
                tokio::io::copy(&mut item.unwrap().as_ref(), &mut tmp_file)
                    .await
                    .unwrap();
            }
        });
    }
}

fn write_character_credits(id: &String, credits: String) {
    let mut download_path = tauri::api::path::download_dir().unwrap();
    let folder_name = format!("{}-gallery", id);
    download_path.push(folder_name);
    download_path.push("credits.txt");

    fs::write(download_path, credits).unwrap();
}

fn write_character_metadata(id: &String, metadata: String) {
    let mut download_path = tauri::api::path::download_dir().unwrap();
    let folder_name = format!("{}-gallery", id);
    download_path.push(folder_name);
    download_path.push("metadata.txt");

    fs::write(download_path, metadata).unwrap();
}

fn write_character_logs(id: &String, logs: String) {
    let mut download_path = tauri::api::path::download_dir().unwrap();
    let folder_name = format!("{}-gallery", id);
    download_path.push(folder_name);
    download_path.push("ownership.txt");

    fs::write(download_path, logs).unwrap();
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![greet, download_character])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
