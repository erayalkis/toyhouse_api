import { defineStore } from "pinia";
import { Ref, computed, ref } from "vue";

export const useRaffleStore = defineStore("raffleOptions", () => {
  const defaultOptions = {
    character: {
      name: "",
      image: "",
      owner: {
        name: "",
        profile: "",
      },
    },
    must_comment: false,
    comment_points: 1,
    must_subscribe: false,
    subscribe_points: 1,
    must_favorite: true,
    favorite_points: 1,
  };

  const options: Ref<Array<any>> = ref([]);
  const loadedMain = computed(() => options.value.length > 0);

  const addCharacter = (character: any) => {
    if (characterAlreadyAdded(character)) return;

    let newoptions = Object.assign({}, defaultOptions);
    newoptions.character = character;

    options.value.push(newoptions);
  };

  const resetCharacter = (character: any) => {
    let characterId = character.id;

    let characterIdx = options.value.findIndex(
      (opt: any) => opt.character.id === characterId
    );

    let newoptions = defaultOptions;
    newoptions.character = character;

    options.value[characterIdx] = newoptions;
  };

  const updateCharacter = (character: any) => {
    let characterId = character.id;

    let characterIdx = options.value.findIndex(
      (opt: any) => opt.character.id === characterId
    );

    options.value[characterIdx] = character;
  };

  const removeCharacter = (character: any) => {
    let characterId = character.id;

    options.value = options.value.filter(
      (opt: any) => opt.character.id !== characterId
    );
  };

  const characterAlreadyAdded = (character: any) => {
    return options.value.some((opt: any) => opt.character.id === character.id);
  };

  return {
    options,
    loadedMain,
    addCharacter,
    resetCharacter,
    updateCharacter,
    removeCharacter,
  };
});
