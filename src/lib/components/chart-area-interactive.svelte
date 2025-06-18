<script lang="ts">
	import { Area, AreaChart, ChartClipPath} from "layerchart";
	import TrendingUpIcon from "@lucide/svelte/icons/trending-up";
	import { curveNatural } from "d3-shape";
	import * as Chart from "$lib/components/ui/chart/index.js";
	import * as Card from "$lib/components/ui/card/index.js";
	import { cubicInOut } from "svelte/easing"
	import { scaleLinear } from "d3-scale";
	import { selectedCountry } from "$lib/stores/filters";


	let chartData = $state<{ year: number; ghg_emissions: number }[]>([]);
	let isLoading = $state(true);
	let error = $state<string | null>(null);

	$effect(() => {
		fetchData($selectedCountry);
	});

	async function fetchData(country:string){
	 try {
			const res = await fetch(`http://localhost:8000/totalghg?country=${country}`);
			if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
			
			const data = await res.json();
			console.log("API Response:", data);

			// Transform data untuk chart
			chartData = data.map((d: { year: number; value: number }) => ({
				year: d.year,
				ghg_emissions: d.value,
			}));

			console.log("Chart Data:", chartData);
			isLoading = false;
		} catch (err) {
			console.error("Error fetching data:", err);
			error = err instanceof Error ? err.message : "Unknown error";
			isLoading = false;
		}
	}

	// onMount(()=> {
	// 	fetchData($selectedCountry)
	// })
  
	const chartConfig = {
	  year: { label: "Year", color: "var(--chart-1)" },
	} satisfies Chart.ChartConfig;
  </script>
  
  <Card.Root>
	<Card.Header>
	  <Card.Title>Total Greenhouse Gas Emissions excluding LULUCF (Mt CO2e)</Card.Title>
	  <Card.Description>Showing total Greenhouse Gas Emissions for all time</Card.Description>
	</Card.Header>
	<Card.Content class="h-[250px]">
	  <Chart.Container config={chartConfig} class="h-full w-full">
		<AreaChart
		
		  data={chartData}
		  x="year"
		  xDomain={[1970, 2023]}
		  yScale={scaleLinear().domain([0, 60000])} 
		  yNice
		  series={[
			{
			  key: "ghg_emissions",
			  label: "Emissions",
			  color: chartConfig.year.color,
			},
		  ]}
		  axis="x"
		  props={{
			area: {
			  curve: curveNatural,
			  "fill-opacity": 0.3,
			  line: { class: "stroke-1" },
			  motion: "tween",
			},
			xAxis: {
			  format: (v: number) => `${v}`
			},
		  }}
		>
			{#snippet marks({ series, getAreaProps })}
			<defs>
			<linearGradient id="fillDesktop" x1="0" y1="0" x2="0" y2="1">
				<stop
				offset="5%"
				stop-color="var(--chart-1)"
				stop-opacity={1.0}
				/>
				<stop
				offset="95%"
				stop-color="var(--chart-1)"
				stop-opacity={0.1}
				/>
			</linearGradient>
			</defs>
			          <ChartClipPath
            initialWidth={0}
            motion={{
              width: { type: "tween", duration: 1000, easing: cubicInOut },
            }}
          >
            {#each series as s, i (s.key)}
              <Area
                {...getAreaProps(s, i)}
                fill="url(#fillDesktop)"
              />
            {/each}
          </ChartClipPath>
			{/snippet}
		  {#snippet tooltip()}
			<Chart.Tooltip
				labelFormatter={(v: number) => `Year: ${v}`}
				indicator="line"
			/>
		  {/snippet}
		</AreaChart>
	  </Chart.Container>
	</Card.Content>
	<Card.Footer>
	  <div class="flex w-full items-start gap-2 text-sm">
		<div class="grid gap-2">
		  <div class="flex items-center gap-2 font-medium leading-none">
			Trending up by 5.2% this month <TrendingUpIcon class="size-4" />
		  </div>
		  <div class="text-muted-foreground flex items-center gap-2 leading-none">
			January - June 2024
		  </div>
		</div>
	  </div>
	</Card.Footer>
  </Card.Root>
  