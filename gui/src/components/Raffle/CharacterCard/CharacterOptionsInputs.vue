<template>
  <div class="md:flex md:justify-between">
    <div class="mb-5">
      <div class="flex items-center gap-1.5">
        <h1 class="text-lg">Should favorite?</h1>
        <input
          type="checkbox"
          class="m-0 p-0 mt-1"
          v-model="mainOpt.must_favorite"
          checked
          disabled
        />
      </div>
      <div class="gap-1 mt-2">
        <div class="flex gap-1">
          <StarIcon class="w-5" />
          <h1>Favorite points:</h1>
        </div>

        <input
          type="number"
          class="rounded-sm disabled:bg-neutral-200"
          v-model="mainOpt.favorite_points"
          :disabled="!mainOpt.must_favorite"
        />
      </div>
    </div>
    <div class="mb-5">
      <div class="flex items-center gap-1.5">
        <h1 class="text-lg">Should subscribe?</h1>
        <input
          type="checkbox"
          class="m-0 p-0 mt-1"
          v-model="mainOpt.must_subscribe"
        />
      </div>
      <div class="gap-1 mt-2">
        <div class="flex gap-1">
          <SubscribeIcon class="w-5" />
          <h1>Subscription points:</h1>
        </div>

        <input
          type="number"
          class="rounded-sm disabled:bg-neutral-200"
          v-model="mainOpt.subscribe_points"
          :disabled="!mainOpt.must_subscribe"
        />
      </div>
    </div>
    <div class="mb-5">
      <div class="flex items-center gap-1.5">
        <h1 class="text-lg">Should comment?</h1>
        <input
          type="checkbox"
          class="m-0 p-0 mt-1"
          v-model="mainOpt.must_comment"
        />
      </div>
      <div class="gap-1 mt-2">
        <div class="flex gap-1">
          <CommentIcon class="w-5" />
          <h1>Comment points:</h1>
        </div>
        <input
          type="number"
          class="rounded-sm disabled:bg-neutral-200"
          v-model="mainOpt.comment_points"
          :disabled="!mainOpt.must_comment"
        />
      </div>
    </div>
  </div>
</template>
<script setup lang="ts">
import { computed } from "vue";
import { storeToRefs } from "pinia";
import { useRaffleStore } from "../../../stores/raffleOptions.ts";
import SubscribeIcon from "../../../assets/components/SubscribeIcon.vue";
import CommentIcon from "../../../assets/components/CommentIcon.vue";
import StarIcon from "../../../assets/components/StarIcon.vue";

let optionsStore = useRaffleStore();
let { options } = storeToRefs(optionsStore);
let mainOpt = computed(() => options.value[0]);

defineProps({
  mainOpt: {
    type: Object,
    default: () => {},
  },
});
</script>
