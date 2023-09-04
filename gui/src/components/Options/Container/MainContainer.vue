<template>
  <div
    class="flex-col text-toyhouse-dark bg-toyhouse-primary-100 border border-toyhouse-primary-200 rounded-sm p-10"
  >
    <h1 class="text-xl font-bold">Change account settings</h1>
    <hr class="w-full h-px bg-toyhouse-primary-300 my-2" />
    <h1 class="font-bold mb-2">Account Credentials</h1>
    <div class="flex flex-col gap-3">
      <input
        class="border w-full border-toyhouse-primary-300 outline-0 p-2 rounded-md indent-1"
        placeholder="Username"
        v-model="username"
      />
      <input
        class="border w-full border-toyhouse-primary-300 outline-0 p-2 rounded-md indent-1"
        type="password"
        placeholder="Password"
        v-model="password"
      />
    </div>

    <div class="flex justify-center mt-5">
      <button
        class="w-1/3 bg-toyhouse-button-primary text-white transition duration-300 ease-out p-1 rounded-md hover:bg-toyhouse-button-secondary disabled:bg-toyhouse-button-secondary disabled:cursor-not-allowed"
        type="button"
        @click="updateCredentials"
      >
        Update Credentials
      </button>
    </div>
  </div>
</template>
<script setup lang="ts">
import { onBeforeMount, ref } from "vue";
import { relaunch } from "@tauri-apps/api/process";
import { ask } from "@tauri-apps/api/dialog";
import {
  writeTextFile,
  BaseDirectory,
  exists,
  createDir,
  readTextFile,
} from "@tauri-apps/api/fs";
import { appConfigDir } from "@tauri-apps/api/path";
import { parseEnvString } from "@/lib/env";

const username = ref("");
const password = ref("");

onBeforeMount(async () => {
  const envContent = await readFromEnvFile();
  const parsed = parseEnvString(envContent);

  if (parsed["TOYHOUSE_USERNAME"]) {
    username.value = parsed["TOYHOUSE_USERNAME"];
  }

  if (parsed["TOYHOUSE_PASSWORD"]) {
    password.value = parsed["TOYHOUSE_PASSWORD"];
  }
});

const readFromEnvFile = async (): Promise<string> => {
  const envContents = await readTextFile(".env", {
    dir: BaseDirectory.AppConfig,
  });

  return envContents;
};

const createCfgFolderIfNotExists = async () => {
  const appCfg = await appConfigDir();
  const cfgDirExists = await exists(`${appCfg}`);

  if (!cfgDirExists) {
    createDir(`${appCfg}`);
  }
};

const updateCredentials = async () => {
  const confirmation = await ask(
    "Updating the credentials will restart the app, are you sure you entered valid data?"
  );
  if (!confirmation) return;

  await createCfgFolderIfNotExists();

  const fileContents = `TOYHOUSE_USERNAME=${username.value}\nTOYHOUSE_PASSWORD=${password.value}`;
  await writeTextFile(".env", fileContents, { dir: BaseDirectory.AppConfig });
  await relaunch();
};
</script>
