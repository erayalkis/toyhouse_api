import { Router, createRouter, createWebHashHistory } from "vue-router";
import DownloaderView from "../views/DownloaderView.vue";
import RaffleView from "../views/RaffleView.vue";
import type { Route } from "../lib/interfaces/route";

const routes: Array<Route> = [
  { path: "/downloader", component: DownloaderView },
  { path: "/raffle", component: RaffleView },
];

const router: Router = createRouter({
  history: createWebHashHistory(),
  routes,
});

export default router;
