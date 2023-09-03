<template>
  <template v-if="!participants.loaded">
    <div class="participants-wrapper" >
      <h1>No participants loaded!</h1>
    </div>
  </template>
  <template v-else>
    <input class="participants-input" type="text" placeholder="Search user by name..." @input="createDebounce" />
    <div class="participants-wrapper">
      <div class="participants-list">
        <template v-for="user in filteredUsers" :key="user[0]">
          <ParticipantCard :details="user[1]" :username="user[0]" />
        </template>
      </div>
    </div>
  </template>
</template>

<script setup>
  import { participants } from '@/state/participants';
  import { computed, ref } from 'vue';
  import ParticipantCard from './ParticipantCard.vue';

  const query = ref('');
  let timer;

  const filteredUsers = computed(() => {
    if(query.value.length == 0) return Object.entries(participants.list);
    // const newObj = {};

    // let keys = Object.keys(participants.list);

    // keys.forEach((key) => {
    //   if(key.toLowerCase().includes(query.value.toLowerCase())) {
    //     newObj[key] = participants.list[key];
    //   }
    // })

    let filtered = Object.entries(participants.list).filter(
      ([key]) => key.toLowerCase().includes(query.value.toLowerCase()) 
    )

    console.log(filtered);
    return filtered;
  })

  function createDebounce(event) {
    if(timer) timer = clearTimeout(timer);

    timer = setTimeout(function() {
      query.value = event.target.value;
    }, 500)
  }
</script>

<style scoped>

  .participants-wrapper {
    display: flex;
    margin-top: 20px;
    width: 100%;
    height: 80vh;
    justify-content: center;
    overflow-y: scroll;
  }

  .participants-input {
    margin-top: 30px;
  }
  .participants-list {
    display: flex;
    flex-wrap: wrap;
    width: 60%;
    flex-shrink: 5;
  }

  .participant {
    margin: 30px;
    text-align: center;
    border: 1px solid lightblue;
  }

  .participant-image {
    border-bottom: 1px solid lightblue;
    width: 200px;
    height: 200px;
    cursor: pointer;
  }

  .participant-tickets {
    display: flex;
    justify-content: center;
  }

  .ticket-buttons {
    display: flex;
    flex-direction: column;
    margin-left: 10px;
  }
  .ticket-button {
    align-self: center;
    width: 20px;
  }
</style>
