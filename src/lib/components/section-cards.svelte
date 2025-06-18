<script lang="ts">
	import { onMount } from 'svelte';
	import TrendingDownIcon from "@tabler/icons-svelte/icons/trending-down";
	import TrendingUpIcon from "@tabler/icons-svelte/icons/trending-up";
	import { Badge } from "$lib/components/ui/badge/index.js";
	import * as Card from "$lib/components/ui/card/index.js";
	import { selectedCountry } from "$lib/stores/filters";

	$effect(() => {
		fetchCountryGHGData($selectedCountry);
	});

	let countryGHGDataTotal = $state<number | null>(null);
	let countryGHGDataCO2 = $state<number | null>(null);
	let countryGHGDataN2O = $state<number | null>(null);
	let countryGHGDataCH4 = $state<number | null>(null);

	
	async function fetchCountryGHGData(country: string) {
		try {
			const res = await fetch (`http://127.0.0.1:8000/ghg-data?country=${country}`);
			console.log(`http://127.0.0.1:8000/ghg-data?country=${country}`)
			const json = await res.json();
			console.log(json)
			countryGHGDataTotal = json["total"][0].toLocaleString();
			countryGHGDataCO2 = json["co2"][0].toLocaleString();
			countryGHGDataN2O = json["n2o"][0].toLocaleString();
			countryGHGDataCH4 = json["ch4"][0].toLocaleString();
			
		}
		catch (err) {
			console.error("Error fetch country GHG data: ", err);

		}
	}
	onMount(() => {
		fetchCountryGHGData($selectedCountry);
	});
	
</script>

<div
	class="*:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card dark:*:data-[slot=card]:bg-card *:data-[slot=card]:shadow-xs @xl/main:grid-cols-2 @5xl/main:grid-cols-4 grid grid-cols-1 gap-4 px-4 *:data-[slot=card]:bg-gradient-to-t lg:px-6"
>
	<Card.Root class="@container/card">
		<Card.Header>
			<Card.Description>{$selectedCountry} Total Greenhouse Gas Emissions (MTCO2e) in 2023</Card.Description>
			<Card.Title class="@[250px]/card:text-3xl text-2xl font-semibold tabular-nums">
				{countryGHGDataTotal ?? "Loading..."}
			</Card.Title>
			
			<Card.Action>
				<Badge variant="outline">
					<TrendingUpIcon />
					+12.5%
				</Badge>
			</Card.Action>
		</Card.Header>
		<Card.Footer class="flex-col items-start gap-1.5 text-sm">
			<div class="line-clamp-1 flex gap-2 font-medium">
				Trending up this month <TrendingUpIcon class="size-4" />
			</div>
			<div class="text-muted-foreground">Visitors for the last 6 months</div>
		</Card.Footer>
	</Card.Root>
	<Card.Root class="@container/card">
		<Card.Header>
			<Card.Description>Global CO2 (MTCO2e)</Card.Description>
			<Card.Title class="@[250px]/card:text-3xl text-2xl font-semibold tabular-nums">
				{countryGHGDataCO2??"Loading..."}
			</Card.Title>
			<Card.Action>
				<Badge variant="outline">
					<TrendingDownIcon />
					-20%
				</Badge>
			</Card.Action>
		</Card.Header>
		<Card.Footer class="flex-col items-start gap-1.5 text-sm">
			<div class="line-clamp-1 flex gap-2 font-medium">
				Down 20% this period <TrendingDownIcon class="size-4" />
			</div>
			<div class="text-muted-foreground">Acquisition needs attention</div>
		</Card.Footer>
	</Card.Root>
	<Card.Root class="@container/card">
		<Card.Header>
			<Card.Description>Global CH4 (MTCO2e)</Card.Description>
			<Card.Title class="@[250px]/card:text-3xl text-2xl font-semibold tabular-nums">
				{countryGHGDataCH4??"Loading..."}
			</Card.Title>
			<Card.Action>
				<Badge variant="outline">
					<TrendingUpIcon />
					+12.5%
				</Badge>
			</Card.Action>
		</Card.Header>
		<Card.Footer class="flex-col items-start gap-1.5 text-sm">
			<div class="line-clamp-1 flex gap-2 font-medium">
				Strong user retention <TrendingUpIcon class="size-4" />
			</div>
			<div class="text-muted-foreground">Engagement exceed targets</div>
		</Card.Footer>
	</Card.Root>
	<Card.Root class="@container/card">
		<Card.Header>
			<Card.Description>Global N2O (MTCO2e)</Card.Description>
			<Card.Title class="@[250px]/card:text-3xl text-2xl font-semibold tabular-nums">
				{countryGHGDataN2O??"Loading..."}
			</Card.Title>
			<Card.Action>
				<Badge variant="outline">
					<TrendingUpIcon />
					+4.5%
				</Badge>
			</Card.Action>
		</Card.Header>
		<Card.Footer class="flex-col items-start gap-1.5 text-sm">
			<div class="line-clamp-1 flex gap-2 font-medium">
				Steady performance increase <TrendingUpIcon class="size-4" />
			</div>
			<div class="text-muted-foreground">Meets growth projections</div>
		</Card.Footer>
	</Card.Root>
</div>
