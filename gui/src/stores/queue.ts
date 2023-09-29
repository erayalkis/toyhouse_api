import { ref } from "vue";
import { defineStore } from "pinia";
import type { CharacterDetails } from "@/lib/interfaces/toyhouse";

export const useQueueStore = defineStore("queue", () => {
  const queueDefault: Array<CharacterDetails> = [];
  const viewQueueDefault: boolean = false;

  const queue = ref(queueDefault);
  const viewQueue = ref(viewQueueDefault);
  const setQueue = (newValue: Array<CharacterDetails>) =>
    (queue.value = newValue);
  const addToQueue = (queueItem: CharacterDetails) =>
    queue.value.push(queueItem);
  const clearqueue = () => (queue.value = queueDefault);
  const removeCharacter = (id: string) =>
    (queue.value = queue.value.filter((char) => char.id !== id));
  const toggleQueueView = () => (viewQueue.value = !viewQueue.value);

  return {
    viewQueue,
    toggleQueueView,
    addToQueue,
    queue,
    setQueue,
    clearqueue,
    removeCharacter,
  };
});
