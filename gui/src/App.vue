<template>
  <div class="w-screen h-screen">
    <Navbar />
    <router-view></router-view>
    <NotificationModal />
    <AppVersion />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import Navbar from "./components/Navbar.vue";
import NotificationModal from "./components/NotificationModal.vue";
import { Event, listen } from "@tauri-apps/api/event";
import { useEventStore } from "@/stores/event";
import type { EventData } from "@/lib/interfaces/event";
import { useNotificationStore } from "./stores/notification";
import AppVersion from "./components/AppVersion.vue";

const { incrementDownloadCount, deleteData } = useEventStore();
const { pushNotification } = useNotificationStore();

onMounted(async () => {
  await listen("gallery-begin", (event: Event<EventData>) => {
    let payload: EventData = event.payload;
    pushNotification({
      title: `Downloading ${payload.id}`,
      body: `Downloading...`,
      type: "info",
      data: payload,
    });
  });

  await listen("gallery-download-success", (event: Event<EventData>) => {
    let payload: EventData = event.payload;
    incrementDownloadCount(payload.id);
  });

  await listen("gallery-download-fail", (event: Event<EventData>) => {
    let payload: EventData = event.payload;
    deleteData(payload.id);
  });
});
</script>
