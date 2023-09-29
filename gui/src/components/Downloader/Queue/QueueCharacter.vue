<template>
  <div
    class="shrink-0 w-14 lg:w-18 xl:w-20 text-center text-toyhouse-dark overflow-hidden cursor-pointer"
    @dblclick="removeFromQueue"
  >
    <img :src="data.image" />
    <div v-if="targetEventData" class="w-full bg-white rounded-full h-1.5 my-1">
      <div
        class="bg-toyhouse-button-primary h-1.5 rounded-full"
        :style="{
          width: `${
            (targetEventData.downloaded / targetEventData.linksCount) * 100
          }%`,
        }"
      ></div>
    </div>
    <h1 v-if="data.name.length < 13">{{ data.name }}</h1>
    <h1 v-else>{{ data.name.slice(0, 4) + "..." }}</h1>
  </div>
</template>
<script setup lang="ts">
import { useEventStore } from "@/stores/event";
import { useQueueStore } from "@/stores/queue";
import { computed } from "vue";

const { removeCharacter } = useQueueStore();
const eventStore = useEventStore();

const { events } = eventStore;

const props = defineProps({
  data: {
    type: Object,
    default: () => {},
  },
});

const targetEventData = computed(() => events[props.data.id + "-gallery"]);

const removeFromQueue = () => removeCharacter(props.data.id);
</script>
