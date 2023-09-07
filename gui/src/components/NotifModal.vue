<template>
  <div
    v-if="notifications.length"
    class="flex flex-col gap-5 fixed right-5 bottom-5 border border-toyhouse-border-secondary p-5 bg-white rounded-md"
    :class="{
      'bg-red-100': firstNotif.type === 'error',
      'bg-blue-100': firstNotif.type === 'info',
    }"
  >
    <div class="flex justify-between font-bold">
      <X
        class="cursor-pointer"
        title="Clear notifications"
        @click="clearNotifications"
      />
      <h2>{{ firstNotif.title }}</h2>
      <ChevronsRight
        class="cursor-pointer"
        title="Next notification"
        @click="popNotification"
      />
    </div>
    <div>
      <h2>{{ firstNotif.body }}</h2>
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

const notifStore = useNotificationStore();
const { notifications } = storeToRefs(notifStore);
const { clearNotifications, popNotification } = notifStore;

const firstNotif: ComputedRef<Notification> = computed(
  () => notifications.value[0]
);
</script>
