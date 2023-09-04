<template>
  <div>
    <template v-if="chunked.length <= 7">
      <div class="flex items-stretch justify-between">
        <button
          @click="prevPage"
          type="button"
          class="p-2 px-3 cursor-pointer border border-toyhouse-border-primary text-toyhouse-blue-primary rounded-md rounded-r-none hover:bg-gray-100"
        >
          <LeftArrow class="w-4" />
        </button>
        <template v-for="(_, idx) in chunked" :key="idx">
          <p
            @click="$emit('set', idx)"
            class="border border-toyhouse-border-primary text-toyhouse-blue-primary cursor-pointer p-2 px-3 hover:bg-gray-100 border-l-0"
            :class="{
              'bg-toyhouse-blue-primary text-white pointer-events-none':
                currentIndex === idx,
            }"
          >
            {{ idx + 1 }}
          </p>
        </template>
        <button
          @click="nextPage"
          type="button"
          class="p-2 px-3 cursor-pointer border border-toyhouse-border-primary text-toyhouse-blue-primary rounded-md rounded-l-none border-l-0 hover:bg-gray-100"
        >
          <RightArrow class="w-4" />
        </button>
      </div>
    </template>
    <template v-else>
      <div class="flex items-stretch justify-between">
        <button
          @click="prevPage"
          type="button"
          class="p-2 px-3 cursor-pointer border border-toyhouse-border-primary text-toyhouse-blue-primary rounded-md rounded-r-none hover:bg-gray-100"
        >
          <LeftArrow class="w-4" />
        </button>
        <template v-for="(_, idx) in chunked.slice(0, 3)" :key="idx">
          <p
            @click="$emit('set', idx)"
            class="border border-toyhouse-border-primary text-toyhouse-blue-primary cursor-pointer p-2 px-3 hover:bg-gray-100 border-l-0"
            :class="{
              'bg-toyhouse-blue-primary text-white pointer-events-none':
                currentIndex === idx,
            }"
          >
            {{ idx + 1 }}
          </p>
        </template>
        <p
          class="border border-toyhouse-border-primary text-toyhouse-blue-primary cursor-pointer p-2 px-3 hover:bg-gray-100 border-l-0"
        >
          ...
        </p>
        <template
          v-for="n in [
            chunked.length - 3,
            chunked.length - 2,
            chunked.length - 1,
          ]"
          :key="n"
        >
          <p
            @click="$emit('set', n)"
            class="border border-toyhouse-border-primary text-toyhouse-blue-primary cursor-pointer p-2 px-3 hover:bg-gray-100 border-l-0"
            :class="{
              'bg-toyhouse-blue-primary text-white pointer-events-none':
                currentIndex === n,
            }"
          >
            {{ n + 1 }}
          </p>
        </template>
        <button
          @click="nextPage"
          type="button"
          class="p-2 px-3 cursor-pointer border border-toyhouse-border-primary text-toyhouse-blue-primary rounded-md rounded-l-none border-l-0 hover:bg-gray-100"
        >
          <RightArrow class="w-4" />
        </button>
      </div>
    </template>
  </div>
</template>
<script setup lang="ts">
import LeftArrow from "../../../assets/components/LeftArrow.vue";
import RightArrow from "../../../assets/components/RightArrow.vue";

const props = defineProps({
  chunked: {
    type: Array,
    default: () => [],
  },
  currentIndex: {
    type: Number,
    default: 0,
  },
});

const emit = defineEmits(["increment", "decrement", "set"]);

const nextPage = () => {
  if (props.currentIndex < props.chunked.length - 1) {
    emit("increment");
  }
};

const prevPage = () => {
  if (props.currentIndex > 0) {
    emit("decrement");
  }
};
</script>
