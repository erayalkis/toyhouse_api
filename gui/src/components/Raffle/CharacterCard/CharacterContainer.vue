<template>
  <div
    class="flex-col relative overflow-x-hidden p-10 bg-toyhouse-bg-primary border border-toyhouse-border-primary rounded-sm text-toyhouse-text-primary"
  >
    <template v-if="loadedMain">
      <CharacterDetails />
    </template>
    <template v-else>
      <CharacterForm />
    </template>
    <CharacterFormMessages />
  </div>
</template>
<script setup lang="ts">
import { storeToRefs } from "pinia";
import CharacterForm from "./CharacterForm.vue";
import CharacterFormMessages from "./CharacterFormMessages.vue";
import { useRaffleStore } from "../../../stores/raffleOptions.ts";
import CharacterDetails from "./CharacterDetails.vue";

let optsStore = useRaffleStore();
let { loadedMain } = storeToRefs(optsStore);
</script>
