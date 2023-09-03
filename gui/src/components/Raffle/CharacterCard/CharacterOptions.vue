<template>
  <div
    class="options-screen absolute bg-toyhouse-bg-primary w-full h-full top-0 left-0 p-10"
    :class="{ show, 'overflow-y-auto': !show }"
  >
    <div class="relative flex items-center">
      <img
        :src="mainOpt.character.image"
        class="border border-toyhouse-border-primary p-1 bg-white rounded-md w-12"
      />
      <h1 class="text-xl font-semibold sticky">Options</h1>
    </div>

    <hr class="my-2" />

    <CharacterOptionsInputs />
    <CharacterOptionsIncluded />
  </div>
</template>
<script setup>
import { defineProps, computed } from "vue";
import { useRaffleOptionsStore } from "../../../stores/raffleOptions.ts";
import { storeToRefs } from "pinia";
import CharacterOptionsInputs from "./CharacterOptionsInputs.vue";
import CharacterOptionsIncluded from "./CharacterOptionsIncluded.vue";

defineProps({
  show: {
    type: Boolean,
    default: false,
  },
});

let optsStore = useRaffleOptionsStore();
let { opts } = storeToRefs(optsStore);
let mainOpt = computed(() => opts.value[0]);
</script>

<style>
.options-screen {
  margin-left: 2000px;
  transition-property: margin, opacity;
  transition-duration: 700ms;
  transition-timing-function: ease-out;
}

.options-screen.show {
  margin-left: 0px;
  opacity: 100%;
}
</style>
../../../stores/raffleOptions.ts
