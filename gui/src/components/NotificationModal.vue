<template>
  <div
    v-if="notifications.length"
    class="flex flex-col gap-5 fixed right-5 bottom-5 border border-toyhouse-border-secondary p-5 rounded-md"
    :class="[
      'bg-white',
      {
        '!bg-red-200': firstNotif.type === 'error',
        '!bg-blue-200': firstNotif.type === 'info',
      },
    ]"
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
import { computed, ComputedRef } from "vue";
import type { Notification } from "@/lib/interfaces/notification";
import X from "@/assets/components/X.vue";
import ChevronsRight from "@/assets/components/ChevronsRight.vue";
import { useEventStore } from "@/stores/event";
import { EventData } from "@/lib/interfaces/event";

const notifStore = useNotificationStore();
const eventStore = useEventStore();

const { clearNotifications, popNotification } = notifStore;
const { events } = storeToRefs(eventStore);
const { notifications } = storeToRefs(notifStore);

const firstNotif: ComputedRef<Notification> = computed(
  () => notifications.value[0]
);

const firstNotifEventData: ComputedRef<EventData | null> = computed(() => {
  if (firstNotif.value && firstNotif.value.data) {
    return events.value[firstNotif.value.data.id];
  }

  return null;
});
</script>
