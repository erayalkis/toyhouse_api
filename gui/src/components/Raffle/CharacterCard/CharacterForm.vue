<template>
  <div>
    <h3 class="text-xl font-semibold">Toyhouse Raffle</h3>
    <hr class="my-2" />
    <h3 class="font-bold">Character Profile</h3>
    <div class="flex mt-2">
      <input
        v-model="url"
        placeholder="Profile URL"
        class="p-2 border border-toyhouse-border-primary outline-0 rounded-md rounded-r-none w-full indent-1"
      />
      <button
        class="bg-toyhouse-blue-primary text-white p-2 transition duration-300 ease-out rounded-md rounded-l-none hover:bg-toyhouse-button-secondary disabled:bg-toyhouse-button-secondary disabled:cursor-not-allowed"
        type="button"
        :disabled="status === -1 || status === 0"
        @click="load"
      >
        Load
      </button>
    </div>
  </div>
</template>
<script setup lang="ts">
// import { makeQueryFromOptions } from "@/helpers/queryBuilder.js";
import { getCharacterDetails } from "../../../helpers/requests";
import { getCharacterIdFromUrl } from "../../../helpers/url";
import { useRaffleStore } from "@/stores/raffleOptions";
import { useMessagesStore } from "../../../stores/messagesStore.ts";
import { storeToRefs } from "pinia";
import { useStatusStore } from "@/stores/appStatus";
import { ref, computed } from "vue";

const url = ref("");
const messagesStore = useMessagesStore();
const raffleOptionsStore = useRaffleStore();
const statusStore = useStatusStore();

const status = computed(() => statusStore.status);

const { setError, clearError, setLoading, clearLoading } = messagesStore;
const { addCharacter } = raffleOptionsStore;
const { options } = storeToRefs(raffleOptionsStore);

const load = async () => {
  setLoading("Loading your character...");
  let id = getCharacterIdFromUrl(url.value);

  await loadCharacter(id);
};

const ensureCharacterUnique = (id: string) => {
  let alreadyExists = characterExistsInOpts(id);
  if (alreadyExists) {
    throw Error("Character already loaded!");
  }
};

const characterExistsInOpts = (id: string) => {
  console.log(raffleOptionsStore);
  console.log(options.value, id);
  return options.value.some((opt) => opt.character.id === id);
};

const loadCharacter = async (id: string) => {
  try {
    ensureCharacterUnique(id);

    let details = await getCharacterDetails(id);
    if (details.name === "" || details.error) {
      throw Error("Something went wrong while loading your character!");
    }

    addCharacter(details);
  } catch (err: any) {
    setError(err);
    console.error(err);
    setTimeout(() => {
      clearError();
    }, 1500);
  } finally {
    clearLoading();
    url.value = "";
  }
};
</script>
