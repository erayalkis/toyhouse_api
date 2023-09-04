<template>
  <div class="flex flex-wrap gap-5 p-2 mx-5 justify-center">
    <template v-for="key in chunked[currentIndex]" :key="key">
      <div>
        <img
          :src="list[key].profile.image"
          class="w-32 h-32 border border-toyhouse-border-primary p-2"
        />
        <div
          class="bg-gray-100 flex items-center p-0.5 rounded-sm mt-1 border border-toyhouse-border-primary"
        >
          <UserIcon class="w-5 mr-1" />
          <p :title="key">{{ truncateName(key) }}</p>
        </div>

        <div
          class="flex items-center justify-between mt-1 border border-toyhouse-border-primary rounded-md"
        >
          <button
            @click="incrementTicket(key)"
            type="button"
            class="border-r px-1 hover:bg-gray-100"
          >
            <PlusIcon class="w-4 text-toyhouse-blue-primary" />
          </button>
          <p>{{ list[key].ticket_count }}</p>
          <button
            @click="decrementTicket(key)"
            type="button"
            class="border-l px-1 hover:bg-gray-100"
          >
            <MinusIcon class="w-4 text-toyhouse-blue-primary" />
          </button>
        </div>
      </div>
    </template>
  </div>
</template>
<script setup lang="ts">
import { useParticipantsStore } from "../../../stores/participantsStore";
import { storeToRefs } from "pinia";
import UserIcon from "../../../assets/components/UserIcon.vue";
import MinusIcon from "../../../assets/components/MinusIcon.vue";
import PlusIcon from "../../../assets/components/PlusIcon.vue";

const pStore = useParticipantsStore();
const { list } = storeToRefs(pStore);

const truncateName = (name: string) => {
  if (name.length >= 12) {
    return name.slice(0, 9) + "...";
  }
  return name;
};
const incrementTicket = (username: string) =>
  (list.value[username].ticket_count += 1);
const decrementTicket = (username: string) => {
  let user = list.value[username];

  if (user.ticket_count === 1) return;

  user.ticket_count -= 1;
};

defineProps({
  chunked: {
    type: Array,
    default: () => [],
  },
  currentIndex: {
    type: Number,
    default: 0,
  },
});
</script>
