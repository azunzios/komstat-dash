import { writable } from "svelte/store";

export const selectedCountry = writable<string>("World");