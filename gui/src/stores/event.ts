import { Ref, ref } from "vue";
import { defineStore } from "pinia";
import type { EventData } from "@/lib/interfaces/event";

export const useEventStore = defineStore("event", () => {
  const downloadInProgress: Ref<boolean> = ref(false);
  const events: Ref<Record<string, EventData>> = ref({});
  const openFolderAfterSuccess = ref(false);

  const addToEvents = (key: string, val: EventData) =>
    (events.value[key] = val);

  const toggleDlProgress = () =>
    (downloadInProgress.value = !downloadInProgress.value);

  const incrementDownloadCount = (key: string) =>
    (events.value[key].downloaded += 1);
  const deleteData = (key: string) => delete events.value[key];
  const setBlockOpen = (val: boolean) => (openFolderAfterSuccess.value = val);

  return {
    events,
    openFolderAfterSuccess,
    downloadInProgress,
    toggleDlProgress,
    addToEvents,
    incrementDownloadCount,
    deleteData,
    setBlockOpen,
  };
});
