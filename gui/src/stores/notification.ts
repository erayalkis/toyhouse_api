import { Ref, ref } from "vue";
import { defineStore } from "pinia";
import type { Notification } from "@/lib/interfaces/notification";

export const useNotificationStore = defineStore("notification", () => {
  const notifications: Ref<Array<Notification>> = ref([]);

  const pushNotification = (notif: Notification) =>
    notifications.value.push(notif);
  const popNotification = () => notifications.value.pop();
  const removeNotification = (idx: number) =>
    notifications.value.splice(idx, 1);

  return {
    notifications,
    pushNotification,
    popNotification,
    removeNotification,
  };
});
