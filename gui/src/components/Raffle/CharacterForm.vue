<template>
  <div class="form-wrapper">
    <div class="title">
      <h3>
        {{
          participants.winners.length > 0
            ? `Winners #${winnersListIndex} | ${new Date().toLocaleDateString()}`
            : "Raffle"
        }}
      </h3>
      <small v-if="participants.winners.length > 0"
        ><em>{{ Date.now() }}</em></small
      >
      <hr />
    </div>
    <template v-if="!participants.winners.length">
      <form
        id="load-user-form"
        @submit.prevent="loadCharacter"
        v-if="!participants.loaded"
      >
        <input
          class="load-user-input"
          :disabled="participants.loaded"
          placeholder="Enter raffle character URL..."
          v-model="urlInput"
        />
        <button
          class="load-user-button"
          type="submit"
          :disabled="participants.loaded"
        >
          {{ buttonText }}
        </button>
      </form>
      <div class="winners-input" v-if="participants.loaded">
        <h3>How many winners should be picked?</h3>
        <input
          type="number"
          min="0"
          placeholder="Number of winners"
          v-model="winnersCount"
        />
      </div>
      <button
        class="pick-winners"
        v-if="participants.loaded"
        @click="pickWinners"
      >
        Pick winners!
      </button>
      <button
        class="delete-participants delete-full"
        v-if="participants.loaded"
        @click="participants.deleteParticipants"
      >
        Delete current participants list?
      </button>
      <template v-if="!participants.loaded">
        <div class="options-wrapper">
          <div class="shouldComment">
            <div>
              <label for="shouldComment">Comments give extra tickets?</label>
              <input
                type="checkbox"
                id="shouldComment"
                v-model="shouldComment"
              />
            </div>
            <div class="shouldCommentInput">
              <label for="commentCount"
                ><abbr
                  title="Amount of tickets users can earn by commenting on the raffle character."
                  >Comment ticket count</abbr
                ></label
              >
              <br />
              <input
                :disabled="!shouldComment"
                type="number"
                min="0"
                v-model="commentCount"
              />
            </div>
          </div>
          <div class="shouldSub">
            <div>
              <label for="shouldSubscribe"
                >Subscriptions give extra tickets?</label
              >
              <input type="checkbox" id="shouldSubscribe" v-model="shouldSub" />
            </div>
            <div class="shouldSubInput">
              <label for="subCount"
                ><abbr
                  title="Amount of tickets users can earn by subscribing to raffle host. (Requires host's subscribers to be public)"
                  >Subscription ticket count</abbr
                ></label
              >
              <br />
              <input
                :disabled="!shouldSub"
                type="number"
                min="0"
                v-model="subCount"
              />
            </div>
          </div>
        </div>
      </template>
    </template>
    <template v-else>
      <div class="winners">
        <template :key="user" v-for="user in participants.winners">
          <div class="winner">
            <img
              class="winner-img"
              :src="user[Object.keys(user)[0]].image"
              @dblclick="rerollWinner(Object.keys(user)[0])"
            />
            {{ Object.keys(user)[0] }}
            {{ user.ticket_count }}
          </div>
        </template>
      </div>
      <button @click="restartPick" class="delete-participants">Restart</button>
      <button @click="pickWinners" class="reroll-participants">
        Reroll all
      </button>
    </template>

    <div class="messages">
      <h3 class="errorMsg">{{ messages.error }}</h3>
      <h3 class="loadingMsg">{{ messages.loading }}</h3>
    </div>
  </div>
  <h1 class="text-white bg-red-500">ababa</h1>

  <div class="text">
    <h1>Hi there!</h1>
    <hr />
    <h3 class="text-sm">
      This is a free tool for Toyhou.se that let's you pick raffle winners
      efficiently!
      <br />
      To use the app, simply enter the raffle characters link, select any
      optional rules you want, and load the participants!
      <br />
      Afterwards, you can pick any number of winners you want with just the
      click of a button! :) You may also increase or decrease ticket counts, and
      delete users from the participants list!
    </h3>
  </div>
</template>

<script setup>
import { messages } from "@/state/messages";
import { participants } from "@/state/participants";
import { ref, computed, watch } from "vue";

const urlInput = ref("");
const shouldComment = ref(false);
const shouldSub = ref(false);
const subCount = ref(1);
const commentCount = ref(1);
const winnersCount = ref(1);
const winnersListIndex = ref(0);
const buttonText = computed(() => {
  return participants.loaded ? "Ready" : "Load";
});

watch(urlInput, () => {
  messages.clearError();
});

const loadCharacter = async () => {
  messages.clearError();

  const characterUrl = urlInput.value;
  if (!characterUrl || !characterUrl.startsWith("https://toyhou.se")) {
    messages.setError("Please enter a valid Toyhou.se link!");
    return;
  }

  const characterId = parseCharacterUrl(characterUrl);
  const users = await fetchTickets(characterId);
  if (!users) return;

  participants.setParticipants(users);
  urlInput.value = "";
};

const parseCharacterUrl = (url) => {
  const characterId = url.split("/")[3];
  return characterId;
};

const fetchTickets = async (id) => {
  messages.loading = "Fetching participant data...";
  if (shouldSub.value) messages.loading += " (this might take a while...)";

  let users;
  try {
    users = await fetch(createApiUrl(id));
  } catch (e) {
    console.log(e);
    messages.setError("Invalid character link or subscribers hidden!");
  }
  messages.loading = "";

  if (!users.ok) {
    participants.deleteParticipants(false);
    messages.setError("Invalid character link or subscribers hidden!");

    console.log(messages.error);
    return;
  }
  participants.loaded = true;
  return await users.json();
};

const createApiUrl = (id) => {
  let base = `https://toyhouse-api.onrender.com/raffle/${id}?`;

  if (shouldComment.value) {
    base += "must_comment=true&";
    base += `comment_ticket_count=${commentCount.value}&`;
  }

  if (shouldSub.value) {
    base += "must_subscribe=true&";
    base += `subscribe_ticket_count=${subCount.value}&`;
  }

  return base;
};

const pickWinners = () => {
  if (winnersCount.value === 0) return;

  console.log(participants.winners);
  if (participants.winners.length > 0) {
    const confirmReroll = confirm(
      "Are you sure you want to reroll all winners?"
    );
    if (!confirmReroll) return;
  }

  winnersListIndex.value += 1;
  participants.winnersArray(winnersCount.value);
};

const restartPick = () => {
  winnersListIndex.value = 0;
  winnersCount.value = 1;
  participants.deleteParticipants();
};

const rerollWinner = (id) => {
  participants.rerollWinner(id);
};
</script>

<style scoped>
.load-user-input {
  width: 40em;
  height: 3.5em;
  padding: 10px;
  font-size: 17px;
  border-radius: 5px 0 0 5px;
  border-width: 1px 0px 1px 1px;
  border-color: #e3e3e3;
  border-style: solid;
  box-sizing: border-box;
  outline: none;
  transition-property: border, box-shadow;
  transition-duration: 200ms;
  border: 1px solid #d7d7d7;
  box-shadow: 0px 0px 3px #008bba00;
}

.load-user-input:focus {
  border: 1px solid #008bba8a;
  box-shadow: 0px 0px 4px #008bba8a;
}

.load-user-input::placeholder {
  padding-left: 5px;
}

.load-user-input:disabled {
  background-color: #e4e4e4;
}
.load-user-button {
  height: 4.5em;
  width: 5em;
  border: 0;
  border-radius: 0 5px 5px 0;
  background-color: #008cba;
  color: white;
  cursor: pointer;
  transition: background-color, 200ms;
}

.load-user-button:hover {
  background-color: #006687;
}

.load-user-button:disabled {
  background-color: #006687;
  cursor: not-allowed;
}

.form-wrapper {
  border: 1px solid #e3e3e3;
  height: 22em;
  width: 50em;
  background-color: rgba(247, 247, 247, 255);
  border-radius: 10px;
  display: flex;
  margin-top: 50px;
  position: relative;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.options-wrapper {
  display: flex;
  justify-content: space-around;
  width: 100%;
}

.shouldComment {
  margin-top: 30px;
  width: 500px;
  user-select: none;
}

input#shouldComment {
  margin-left: 10px;
  margin-bottom: 25px;
}

input#shouldComment:checked {
  background-color: #008cba;
}

input#shouldSubscribe {
  margin-left: 10px;
  margin-bottom: 25px;
}

.shouldSub {
  display: flex;
  flex-direction: column;
  margin-top: 30px;
  justify-content: center;
  width: 500px;
  user-select: none;
}

.title {
  width: 100%;
  text-align: left;
  margin-left: 50px;
  margin-bottom: 20px;
  margin-top: 10px;
}

hr {
  margin-top: 10px;
  border: 0;
  height: 1px;
  color: #e2e2e2;
  background-color: #e2e2e2;
  width: 95%;
}

.messages {
  padding-top: 50px;
}

.errorMsg {
  color: rgb(255, 46, 46);
}

.text {
  margin-top: 50px;
  width: 60%;
}

.text-sm {
  margin-top: 20px;
  line-height: 1.6rem;
  color: #404244;
}

div.shouldCommentInput > label {
  cursor: help;
}

div.shouldSubInput > label {
  cursor: help;
}

abbr {
  cursor: help;
}

.delete-participants {
  height: 2em;
  width: 50%;
  border: 0;
  border-radius: 0 0 0 5px;
  background-color: #d9534f;
  color: white;
  font-size: 14px;
  cursor: pointer;
  transition: background-color, 200ms;
  position: absolute;
  bottom: 0;
  margin-right: 400px;
}

.delete-full {
  width: 100%;
  border-radius: 0 0 5px 5px;
  margin: 0;
}

.reroll-participants {
  height: 2em;
  width: 50%;
  border: 0;
  border-radius: 0 0 5px 0;
  background-color: #008cba;
  color: white;
  font-size: 14px;
  cursor: pointer;
  transition: background-color, 200ms;
  position: absolute;
  bottom: 0;
  margin-left: 400px;
}

.delete-participants:hover {
  background-color: #c9302c;
}

.reroll-participants:hover {
  background-color: #006687;
}

.pick-winners {
  height: 4.5em;
  width: 50em;
  border: 0;
  border-radius: 5px 5px 5px 5px;
  background-color: #008cba;
  color: white;
  font-size: 14px;
  cursor: pointer;
  transition: background-color, 200ms;
}

.pick-winners:hover {
  background-color: #006687;
}

.winners-input {
  display: flex;
  width: 100%;
  justify-content: space-around;
  align-items: center;
  margin-bottom: 50px;
}

.winners-input input {
  height: 23px;
  box-sizing: border-box;
}

.winners {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  overflow-y: scroll;
  width: 100%;
  height: 90%;
  margin-bottom: 30px;
}

.winner {
  width: 30%;
  height: 30%;
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 20px 5px 20px 5px;
}

.winner-img {
  height: 5rem;
  width: 5rem;
  cursor: pointer;
}
</style>
