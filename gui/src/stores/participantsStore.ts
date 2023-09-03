import { defineStore } from "pinia";
import { Ref, computed, ref } from "vue";
import { chunkArray } from "../helpers/requests.ts";

export const useParticipantsStore = defineStore("participants", () => {
  const list: Ref<Record<string, any>> = ref({});
  const searchResults = ref({});
  const winners: Ref<Record<string, any>> = ref({});
  const usersByTicketCount: Ref<Array<any>> = ref([]);
  const loaded = computed(() => Object.keys(list.value).length === 0);
  const chunked = computed(() => {
    if (Object.keys(searchResults.value).length) {
      return chunkArray(Object.keys(searchResults.value), 30);
    }

    return chunkArray(Object.keys(list.value), 30);
  });

  const setParticipants = (obj: Object) => (list.value = obj);
  const setWinners = (obj: Object) => (winners.value = obj);
  const setSearchResults = (obj: Object) => (searchResults.value = obj);

  const deleteParticipants = () => {
    list.value = {};
    deleteWinners();
    deleteSearchResults();
  };

  const deleteSearchResults = () => (searchResults.value = {});
  const deleteWinners = () => (winners.value = {});

  const remove = (user: string) => delete list.value[user];

  const increment = (user: string) => {
    list.value[user].ticket_count += 1;
  };

  const decrement = (user: string) => {
    list.value[user].ticket_count -= 1;
  };

  const pickWinners = (winnersCount: number) => {
    setDupedUsers();

    // Set of usernames
    let seenUsers = new Set();
    let winners: Record<string, any> = {};

    for (winnersCount; winnersCount > 0; winnersCount--) {
      const idx = getRandomIndex(usersByTicketCount.value.length);
      const selectedUser = usersByTicketCount.value[idx];

      const username = selectedUser.profile.name;
      let inSeen = seenUsers.has(username);
      if (!inSeen) {
        seenUsers.add(username);
        winners[username] = selectedUser;
      } else {
        winnersCount += 1;
        continue;
      }
    }

    return winners;
  };

  const setDupedUsers = () => {
    usersByTicketCount.value = [];

    const usersDupedByTicketCount: Array<any> = [];

    Object.keys(list.value).forEach((username) => {
      let user = list.value[username];
      usersDupedByTicketCount.push(user);
    });

    usersByTicketCount.value = usersDupedByTicketCount;
  };

  const getRandomIndex = (length: number) => Math.floor(Math.random() * length);
  const rerollWinner = (username: string) => {
    const dupedWinnersWithoutTarget = usersByTicketCount.value.filter(
      (user) => user.profile.name != username
    );

    const newWinnerIndex = getRandomIndex(dupedWinnersWithoutTarget.length);

    winners.value[username] = dupedWinnersWithoutTarget[newWinnerIndex];
  };

  const getUsersWithMatchingName = (username: string) => {
    let matches: Record<string, any> = {};
    let usernames = Object.keys(list.value).filter((userKey) => {
      console.log(userKey, username);
      return userKey.toLowerCase().includes(username.toLowerCase());
    });

    usernames.forEach((username) => (matches[username] = list.value[username]));

    return matches;
  };

  return {
    list,
    chunked,
    winners,
    loaded,
    setParticipants,
    setWinners,
    deleteParticipants,
    remove,
    increment,
    decrement,
    pickWinners,
    getRandomIndex,
    rerollWinner,
    getUsersWithMatchingName,
    searchResults,
    setSearchResults,
    deleteSearchResults,
  };
});
