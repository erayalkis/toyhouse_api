import { createApp } from "vue";
import "./styles.css";
import App from "./App.vue";
import router from "./router/router";
import { createPinia } from "pinia";
import { Command } from "@tauri-apps/api/shell";
import { exists, BaseDirectory } from "@tauri-apps/api/fs";
import { message } from "@tauri-apps/api/dialog";

const envExists = exists(".env", { dir: BaseDirectory.AppConfig });

if (!envExists) {
  router.push({ path: "/options" });
  message(
    "It seems that you do not have any login info saved on this machine, please update it before using the app."
  );
}

const cmd = Command.sidecar("bin/main", [], {
  env: {
    TOYHOUSE_USERNAME: "toyhouse_downloader",
    TOYHOUSE_PASSWORD: "arda159852456",
  },
});
const sidecar_output = await cmd.spawn();
console.log("PID", sidecar_output);
const app = createApp(App);
const pinia = createPinia();

app.use(router);
app.use(pinia);

app.mount("#app");
