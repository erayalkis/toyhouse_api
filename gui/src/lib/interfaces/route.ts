import type { Component } from "vue";

export interface Route {
  name: string;
  path: string;
  component: Component;
}
