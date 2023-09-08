<template>
  <div
    v-if="notifications.length"
    class="flex flex-col gap-5 fixed right-5 bottom-5 border border-toyhouse-border-secondary p-5 bg-white rounded-md"
    :class="{
      'bg-red-200': firstNotif.type === 'error',
      'bg-blue-200': firstNotif.type === 'info',
    }"
  >
    <div class="flex justify-between font-bold gap-5">
      <X
        class="cursor-pointer"
        title="Clear notifications"
        @click="clearNotifications"
      />
      <div>
        <h2>{{ firstNotif.title }}</h2>
        <template v-if="firstNotifEventData">
          <p class="text-sm font-light opacity-75 text-center">
            {{ firstNotifEventData.downloaded }} /
            {{ firstNotifEventData.linksCount }}
          </p>
        </template>
      </div>
      <ChevronsRight
        class="cursor-pointer"
        :class="{ 'cursor-default opacity-25': notifications.length == 1 }"
        title="Next notification"
        @click="popNotification"
      />
    </div>
    <div v-if="!firstNotifEventData">
      <h2>{{ firstNotif.body }}</h2>
    </div>
    <div v-else class="text-center">
      <div class="w-full bg-white rounded-full h-1.5 mb-4">
        <div
          class="bg-toyhouse-button-primary h-1.5 rounded-full"
          :style="{
            width: `${
              (firstNotifEventData.downloaded /
                firstNotifEventData.linksCount) *
              100
            }%`,
          }"
        ></div>
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { useNotificationStore } from "@/stores/notification";
import { storeToRefs } from "pinia";
import { computed, ComputedRef, watch } from "vue";
import type { Notification } from "@/lib/interfaces/notification";
import X from "@/assets/components/X.vue";
import ChevronsRight from "@/assets/components/ChevronsRight.vue";
import { useEventStore } from "@/stores/event";
import { EventData } from "@/lib/interfaces/event";
import { open } from "@tauri-apps/api/shell";
import { downloadDir } from "@tauri-apps/api/path";
import { useQueueStore } from "@/stores/queue";

const notifStore = useNotificationStore();
const eventStore = useEventStore();
const qStore = useQueueStore();

const { deleteData, setBlockOpen } = eventStore;
const { removeCharacter } = qStore;
const { clearNotifications, popNotification } = notifStore;
const { events, openFolderAfterSuccess } = storeToRefs(eventStore);
const { notifications } = storeToRefs(notifStore);
const { viewQueue, queue } = storeToRefs(qStore);

const firstNotif: ComputedRef<Notification> = computed(
  () => notifications.value[0]
);

const firstNotifEventData: ComputedRef<EventData | null> = computed(() => {
  if (firstNotif.value && firstNotif.value.data) {
    return events.value[firstNotif.value.data.id];
  }

  return null;
});

watch(
  () => firstNotifEventData.value?.downloaded,
  async (val) => {
    if (val && val == firstNotifEventData.value?.linksCount) {
      const dlPath = await downloadDir();
      const eventCharId = firstNotif.value.data?.id;
      const fullPath = dlPath + eventCharId;

      popNotification();
      deleteData(eventCharId);
      if (viewQueue.value && queue.value.length) {
        const currChar = queue.value[0];
        removeCharacter(currChar.id);
      }

      if (Object.keys(events.value).length === 0 && queue.value.length === 0) {
        console.log("opening folder from queue logic");
        open(dlPath, "open");
        setBlockOpen(false);
        return;
      }

      if (!openFolderAfterSuccess.value) {
        console.log("opening folder from single dl logic");
        open(fullPath, "open");
      }
    }
  }
);
</script>
