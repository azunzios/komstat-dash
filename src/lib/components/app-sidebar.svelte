<script lang="ts">
	import ChartBarIcon from "@tabler/icons-svelte/icons/chart-bar";
	import DashboardIcon from "@tabler/icons-svelte/icons/dashboard";
	import DatabaseIcon from "@tabler/icons-svelte/icons/database";
	import HelpIcon from "@tabler/icons-svelte/icons/help";
	import IconUser from "@tabler/icons-svelte/icons/user";
	import InnerShadowTopIcon from "@tabler/icons-svelte/icons/inner-shadow-top";
	import ReportIcon from "@tabler/icons-svelte/icons/report";
	import NavMain from "./nav-main.svelte";
	import NavSecondary from "./nav-secondary.svelte";
	import * as Sidebar from "$lib/components/ui/sidebar/index.js";
	import type { ComponentProps } from "svelte";
	const data = {
	  navMain: [
		{
		  title: "Dashboard",
		  url: "#",
		  icon: DashboardIcon,
		},
		{
		  title: "Tool Analisis",
		  url: "#",
		  icon: ChartBarIcon,
		},
		{
			title: "Hasil Analisis",
			url: "#",
			icon: ReportIcon,
		},
		{
			title: "Metadata",
			url: "#",
			icon: DatabaseIcon,
		}
	  ],
	  navSecondary: [
		{
		  title: "Petunjuk",
		  url: "#",
		  icon: HelpIcon,
		},
		{
		title: "Tentang kami",
		url: "#group-member",
		icon: IconUser,
		}
	  ],
	};
	let { ...restProps }: ComponentProps<typeof Sidebar.Root> = $props();
	let showInfo = false;
  </script>

  <Sidebar.Root collapsible="icon" {...restProps} class="w-10 ml-0">

	<Sidebar.Content class="mx-auto mt-20 p-0">
	  <NavMain items={data.navMain} />
	  <NavSecondary items={data.navSecondary} class="mt-auto" />
	</Sidebar.Content>
  </Sidebar.Root>