import { createApp } from "vue";
import "./styles.css";
import App from "./App.vue";
import router from "./router/router";
import { createPinia } from "pinia";
import { Command } from "@tauri-apps/api/shell";
import { exists, BaseDirectory, readTextFile } from "@tauri-apps/api/fs";
import { message } from "@tauri-apps/api/dialog";
import { parseEnvString } from "./lib/env";

const envExists = await exists(`.env`, { dir: BaseDirectory.AppConfig });

if (!envExists) {
  router.push({ path: "/options" });
  message(
    "It seems that you do not have any login info saved on this machine, please update it before using the app."
  );
}

const envContents = await readTextFile(".env", {
  dir: BaseDirectory.AppConfig,
});

const parsed = parseEnvString(envContents);

console.log("Starting child process with env", parsed);
const cmd = Command.sidecar("bin/main", [], {
  env: parsed,
});
const sidecar_output = await cmd.spawn();
console.log("PID", sidecar_output);
const app = createApp(App);
const pinia = createPinia();

app.use(router);
app.use(pinia);

app.mount("#app");
