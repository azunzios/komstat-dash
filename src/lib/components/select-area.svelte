<script lang="ts">
  import * as Select from "$lib/components/ui/select/index.js";
  import { selectedCountry } from "$lib/stores/filters";
  import { onMount } from "svelte";

  let allCountries = $state<{ value: string; label: string }[]>([]);

  onMount(async () => {
    const res = await fetch("http://localhost:8000/countrylist");
    const data = await res.json();
    allCountries = data.map((d: { [key: string]: string }) => ({
      value: d["Country.Name"],
      label: d["Country.Name"],
    }));
  });

  let value = $state("World");
  let search = $state("");

  const filtered = $derived(
    allCountries.filter((c) =>
      c.label.toLowerCase().includes(search.toLowerCase()),
    ),
  );
  const isPlaceholder = $derived(!allCountries.find((f) => f.value === value));

  const triggerContent = $derived(
    allCountries.find((f) => f.value === value)?.label ?? "Pilih negara/ area",
  );
  $effect(() => {
    if (allCountries.length) {
      selectedCountry.set(value);
    }
  });
</script>

<Select.Root type="single" name="country" bind:value>
  <Select.Trigger class="w-[220px]">
    <span class={isPlaceholder ? "text-muted-foreground" : ""}>
      {triggerContent}
    </span>
  </Select.Trigger>
  <Select.Content>
    <div class="py-1">
      <input
        class="w-full rounded border px-2 py-1 text-sm"
        placeholder="Search country..."
        bind:value={search}
      />
    </div>
    <Select.Group>
      {#each filtered as country (country.value)}
        <Select.Item
          class="w-[220px] whitespace-normal break-words overflow-hidden text-ellipsis"
          value={country.value}
          label={country.label}
        >
          {country.label}
        </Select.Item>
      {/each}
    </Select.Group>
  </Select.Content>
</Select.Root>
