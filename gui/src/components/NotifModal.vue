<template>
  <div class="fixed bottom-0">
    <div>
      <button></button>
      <h2>{{ firstNotif.title }}</h2>
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

const notifStore = useNotificationStore();
const { notifications } = storeToRefs(notifStore);

const firstNotif: ComputedRef<Notification> = computed(
  () => notifications.value[0]
);
</script>
