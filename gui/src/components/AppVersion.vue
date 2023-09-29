<template>
  <div class="absolute bottom-0 left-0 p-2 opacity-25 italic">
    <small>Toyhouse Extensions v{{ appVersion }}</small>
  </div>
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
