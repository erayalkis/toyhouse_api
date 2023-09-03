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
<script setup>
import { storeToRefs } from "pinia";
import CharacterForm from "./CharacterForm.vue";
import CharacterFormMessages from "./CharacterFormMessages.vue";
import { useOptionsStore } from "@/state/optionsStore.js";
import CharacterDetails from "./CharacterDetails.vue";

let optsStore = useOptionsStore();
let { loadedMain } = storeToRefs(optsStore);
</script>
