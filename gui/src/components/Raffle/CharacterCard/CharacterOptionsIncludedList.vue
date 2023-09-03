<template>
  <div
    class="bg-neutral-100 border border-toyhouse-border-primary w-full p-2 flex gap-4 overflow-x-auto rounded-md h-42 rounded-b-none"
  >
    <template v-for="opt in opts.slice(1)" :key="opt.character.id">
      <div class="flex-col p-1">
        <img
          :src="opt.character.image"
          class="border border-toyhouse-border-primary p-1 bg-white rounded-md w-14 mx-auto md:w-20"
        />
        <h4 class="text-center">
          {{ truncateNameIfTooLong(opt.character.name) }}
        </h4>
        <div class="flex justify-center gap-5 md:gap-3">
          <div class="flex-col">
            <div class="flex">
              <StarIcon class="w-5 mx-auto" />
              <input v-model="opt.must_favorite" type="checkbox" />
            </div>
            <input
              v-model="opt.favorite_points"
              type="number"
              class="w-10 outline-0 rounded-sm disabled:bg-neutral-200"
              :disabled="!opt.must_favorite"
            />
          </div>

          <div class="flex-col">
            <div class="flex">
              <SubscribeIcon class="w-5 mx-auto" />
              <input v-model="opt.must_subscribe" type="checkbox" />
            </div>
            <input
              v-model="opt.subscribe_points"
              type="number"
              class="w-10 outline-0 rounded-sm disabled:bg-neutral-200"
              :disabled="!opt.must_subscribe"
            />
          </div>

          <div class="flex-col">
            <div class="flex">
              <CommentIcon class="w-5 mx-auto" />
              <input v-model="opt.must_comment" type="checkbox" />
            </div>
            <input
              v-model="opt.comment_points"
              type="number"
              class="w-10 outline-0 rounded-sm disabled:bg-neutral-200"
              :disabled="!opt.must_comment"
            />
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script setup>
import { useRaffleOptionsStore } from "../../../stores/raffleOptions.ts";
import { storeToRefs } from "pinia";
import SubscribeIcon from "../../../assets/components/SubscribeIcon.vue";
import CommentIcon from "../../../assets/components/CommentIcon.vue";
import StarIcon from "../../../assets/components/StarIcon.vue";

const optionsStore = useRaffleOptionsStore();
let { opts } = storeToRefs(optionsStore);

const truncateNameIfTooLong = (name) => {
  if (name.length > 12) return name.slice(0, 9) + "...";
  return name;
};
</script>
../../../stores/raffleOptions.ts
