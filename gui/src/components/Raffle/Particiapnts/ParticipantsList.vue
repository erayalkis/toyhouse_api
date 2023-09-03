<template>
  <div class="flex flex-col justify-center items-center p-1 mt-2">
    <template v-if="chunked.length">
      <h1 class="my-1 mb-2">
        Displaying {{ Object.keys(list).length }} participant(s).
      </h1>
      <ParticipantsListPaginator
        :chunked="chunked"
        :current-index="currentIndex"
        @increment="incrementIndex"
        @decrement="decrementIndex"
        @set="setIndex"
      />
      <ParticipantsListSearchBar />

      <ParticipantsCard :chunked="chunked" :current-index="currentIndex" />
    </template>
    <template v-else>
      <div class="border border-toyhouse-border-primary p-5 rounded-md">
        <h1 class="text-xl font-semibold text-center">
          No participants to show! <br />
          Please load participants from the Home page.
        </h1>
      </div>
    </template>
  </div>
</template>
<script setup lang="ts">
import { useParticipantsStore } from "../../../stores/participantsStore.ts";
import { storeToRefs } from "pinia";
import { ref } from "vue";
import ParticipantsCard from "./ParticipantsCard.vue";
import ParticipantsListPaginator from "./ParticipantsListPaginator.vue";
import ParticipantsListSearchBar from "./ParticipantsListSearchBar.vue";

const pStore = useParticipantsStore();
const { list, chunked } = storeToRefs(pStore);

const currentIndex = ref(0);

const incrementIndex = () => (currentIndex.value += 1);
const decrementIndex = () => (currentIndex.value -= 1);
const setIndex = (idx: number) => (currentIndex.value = idx);
</script>
