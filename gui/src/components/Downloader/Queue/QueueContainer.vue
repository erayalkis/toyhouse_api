<template>
  <div v-if="viewQueue" class="flex items-center shrink-0">
    <div
      class="flex w-full bg-toyhouse-primary-200 border border-toyhouse-primary-400 rounded-md rounded-r-none relative w-2/3 md:w-5/6 lg:w-5/6 2xl:w-11/12"
    >
      <div class="flex items-center gap-10 overflow-y-auto px-3 py-1">
        <template
          v-if="queue.length > 0"
          v-for="character in queue"
          :key="character.id"
        >
          <Character :data="character" />
        </template>
        <template v-else>
          <h1 class="text-sm md:text-base lg:p-5 2xl:p-10">
            No characters in queue!
          </h1>
        </template>
      </div>
    </div>
    <button
      :class="{
        'cursor-not-allowed': queue.length === 0 || downloadInProgress,
      }"
      :disabled="queue.length === 0 || downloadInProgress"
      class="self-stretch right-0 bg-toyhouse-button-primary text-white rounded-md rounded-l-none w-1/3 transition duration-300 ease-out hover:bg-toyhouse-button-secondary disabled:bg-toyhouse-button-secondary md:w-1/6 lg:w-1/6 2xl:w-1/12"
      type="button"
      @click="download"
    >
      <img :src="DownloadSvg" class="w-6 mx-auto lg:w-7 xl:w-8 text-white" />
    </button>
  </div>
</template>
<script setup lang="ts">
import { useQueueStore } from "@/stores/queue";
import { useEventStore } from "@/stores/event";
import DownloadSvg from "@/assets/download.svg";
import Character from "./QueueCharacter.vue";
import { downloadQueue } from "@/lib/download";
import { storeToRefs } from "pinia";
import { watch } from "vue";
import type { EventData } from "@/lib/interfaces/event";
import { useNotificationStore } from "@/stores/notification";
import { downloadDir } from "@tauri-apps/api/path";
import { open } from "@tauri-apps/api/shell";

const eventStore = useEventStore();
const queueStore = useQueueStore();
const notifStore = useNotificationStore();

const { toggleDlProgress, setEvents } = eventStore;
const { clearNotifications } = notifStore;
const { setQueue } = queueStore;

const { queue, viewQueue } = storeToRefs(queueStore);
const { downloadInProgress, events } = storeToRefs(eventStore);

const download = async () => {
  toggleDlProgress();
  await downloadQueue();
  toggleDlProgress();
};

watch(
  events,
  async () => {
    if (!viewQueue.value || !events.value) return;

    console.log("watcher event from queue", events.value);

    const eventValues = Object.values(events.value);

    if (eventValues.length === 0) return;

    const allDone = Object.values(events.value).every(
      (e: EventData) => e.downloaded === e.linksCount
    );

    if (allDone) {
      const dlDir = await downloadDir();

      clearNotifications();
      setQueue([]);
      setEvents({});

      console.log(queue.value, events.value);
      open(dlDir, "open");
    }
  },
  { deep: true }
);
</script>
