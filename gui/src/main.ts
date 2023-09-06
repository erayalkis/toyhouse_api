import { createApp } from "vue";
import "./styles.css";
import App from "./App.vue";
import router from "./router/router";
import { createPinia } from "pinia";
import { Command } from "@tauri-apps/api/shell";
import { exists, BaseDirectory, readTextFile } from "@tauri-apps/api/fs";
import { message } from "@tauri-apps/api/dialog";
import { parseEnvString } from "./lib/env";

exists(`.env`, { dir: BaseDirectory.AppConfig }).then((envExists) => {
  if (!envExists) {
    router.push({ path: "/options" });
    message(
      "It seems that you do not have any login info saved on this machine, please update it before using the app."
    );
  }
});

readTextFile(".env", {
  dir: BaseDirectory.AppConfig,
}).then((envContents) => {
  const parsed = parseEnvString(envContents);

  console.log("Starting child process with env", parsed);
  const cmd = Command.sidecar("binaries/main", [], {
    env: parsed,
  });

  console.log(cmd);

  cmd.execute().then((child) => {
    console.log("CHILD_PROCESS", child);
  });

  cmd.on("error", (err) => {
    console.error(err);
    console.log("ERROR ERROR ERROR ERROR", err, "ERROR ERROR ERROR ERROR");
  });
});

const app = createApp(App);
const pinia = createPinia();

app.use(router);
app.use(pinia);

app.mount("#app");
