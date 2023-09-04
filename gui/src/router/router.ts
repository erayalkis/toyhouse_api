import { Router, createRouter, createWebHashHistory } from "vue-router";
import DownloaderView from "../views/DownloaderView.vue";
import RaffleView from "../views/RaffleView.vue";
import ParticipantsView from "../views/ParticipantsView.vue";
import OptionsView from "@/views/OptionsView.vue";
import type { Route } from "../lib/interfaces/route";

const routes: Array<Route> = [
  { name: "Downloader", path: "/", component: DownloaderView },
  { name: "Raffle", path: "/raffle", component: RaffleView },
  {
    name: "Participants",
    path: "/participants",
    component: ParticipantsView,
  },
  {
    name: "Options",
    path: "/options",
    component: OptionsView,
  },
];

const router: Router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
