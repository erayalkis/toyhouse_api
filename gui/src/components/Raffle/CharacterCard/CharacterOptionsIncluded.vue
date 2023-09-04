<template>
  <div class="my-2">
    <div class="items-center gap-1">
      <h1 class="text-lg">Included characters:</h1>
      <div class="flex">
        <input
          v-model="url"
          placeholder="Profile URL"
          class="p-2 border border-toyhouse-border-primary outline-0 rounded-md rounded-r-none w-full indent-1"
        />
        <button
          class="bg-toyhouse-blue-primary text-white p-2 transition duration-300 ease-out rounded-md rounded-l-none hover:bg-toyhouse-blue-secondary"
          type="button"
          @click="load"
        >
          Load
        </button>
      </div>
      <CharacterFormMessages />
      <CharacterFormOptionsIncludedList />
    </div>
  </div>
</template>
<script setup lang="ts">
import { getCharacterDetails } from "../../../helpers/requests.ts";
import { getCharacterIdFromUrl } from "../../../helpers/url.ts";
import { useRaffleStore } from "../../../stores/raffleOptions.ts";
import { useMessagesStore } from "../../../stores/messagesStore.ts";
import { storeToRefs } from "pinia";
import { ref } from "vue";
import CharacterFormMessages from "./CharacterFormMessages.vue";
import CharacterFormOptionsIncludedList from "./CharacterOptionsIncludedList.vue";

const url = ref("");
const messagesStore = useMessagesStore();
const optionsStore = useRaffleStore();

const { setError, setLoading, clearLoading, clearError } = messagesStore;
const { addCharacter } = optionsStore;
let { options } = storeToRefs(optionsStore);

const load = async () => {
  setLoading("Loading your character...");
  let id = getCharacterIdFromUrl(url.value);

  await loadCharacter(id);
};

const ensureCharacterUnique = (id: string) => {
  let alreadyExists = characterExistsInoptions(id);
  if (alreadyExists) {
    throw Error("Character already loaded!");
  }
};

const characterExistsInoptions = (id: string) => {
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
    setTimeout(() => {
      clearError();
    }, 1500);
    console.error(err);
  } finally {
    clearLoading();
    url.value = "";
  }
};
</script>
