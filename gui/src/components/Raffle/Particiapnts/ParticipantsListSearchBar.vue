<template>
  <div class="flex mt-1.5 items-center">
    <SearchIcon class="text-toyhouse-blue-primary" />
    <input
      v-model="username"
      type="text"
      placeholder="Username..."
      class="outline-0 border border-toyhouse-border-primary indent-1 p-0.5 rounded-md"
      @change="search"
    />
  </div>
</template>
<script setup lang="ts">
import SearchIcon from "../../../assets/components/SearchIcon.vue";
import { useParticipantsStore } from "../../../stores/participantsStore";
import { ref } from "vue";

const username = ref("");

const pStore = useParticipantsStore();
const { getUsersWithMatchingName, setSearchResults } = pStore;

const search = () => {
  if (!username.value.trim().length) {
    username.value = "";
  }

  let res = getUsersWithMatchingName(username.value);

  setSearchResults(res);
};
</script>
