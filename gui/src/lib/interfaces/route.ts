import type { Component } from "vue";

export interface Route {
  component: Component;
  path: string;
}
