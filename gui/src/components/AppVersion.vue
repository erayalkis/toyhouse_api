<template>
  <p>Toyhouse Extensions {{ appVersion }}</p>
</template>
<script setup lang="ts">
import { Ref, onBeforeMount, ref } from "vue";
import { getVersion } from "@tauri-apps/api/app";

onBeforeMount(async () => {
  const version: string = await getVersion();

  appVersion.value = version;
});

const appVersion: Ref<string> = ref("");
</script>
