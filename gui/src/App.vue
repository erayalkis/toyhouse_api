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

const eventStore = useEventStore();
const { incrementDownloadCount, deleteData } = eventStore;
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

// watch(
//   events,
//   () => {
//     // maybe split the logic into queue and download compoennets ?
//     // download just. watches for the counters to match, opens folder
//     // queue watches all event data available, waits for all of them to finish, and opens the folder
//     // check github version and compare to current version, raise error if not matching
//   },
//   { deep: true }
// );
</script>
