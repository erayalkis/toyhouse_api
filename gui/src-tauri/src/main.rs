// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use futures::StreamExt;
use serde::Serialize;
use std::{fs, path::PathBuf, sync::OnceLock};
use tauri::{Manager, Window};

#[derive(Serialize, Clone)]
struct Payload {
    id: String,
}

// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
async fn download_raffle_results(character_name: String, results: String) -> PathBuf {
    let mut dl_path = tauri::api::path::download_dir().unwrap();
    let filename = format!("{}-results.txt", character_name);
    dl_path.push(filename);

    tokio::fs::write(&dl_path, results).await.unwrap();

    dl_path
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
    download_path.push(&folder_name);

    fs::create_dir_all(&download_path).unwrap();
    let window = WINDOW.get().unwrap();
    let payload = Payload { id: folder_name };
    window.emit("gallery-begin", payload).unwrap();

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
    let window = WINDOW.get().unwrap();

    for (idx, mut link) in iter.enumerate() {
        let mut download_path = tauri::api::path::download_dir().unwrap();
        let folder_name = format!("{}-gallery", id);
        download_path.push(&folder_name);

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
            let mut byte_stream;
            match reqwest::get(link).await {
                Ok(resp) => {
                    byte_stream = resp.bytes_stream();
                }
                Err(_) => {
                    let payload = Payload {
                        id: folder_name.clone(),
                    };
                    window.emit("gallery-download-error", payload).unwrap();
                    return;
                }
            };

            while let Some(item) = byte_stream.next().await {
                tokio::io::copy(&mut item.unwrap().as_ref(), &mut tmp_file)
                    .await
                    .unwrap();
            }

            let payload = Payload { id: folder_name };
            window.emit("gallery-download-success", payload).unwrap();
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

static WINDOW: OnceLock<Window> = OnceLock::new();
fn main() {
    tauri::Builder::default()
        .setup(|app| {
            let window = app.get_window("main").unwrap();
            WINDOW.set(window).unwrap();

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            greet,
            download_character,
            download_raffle_results
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
