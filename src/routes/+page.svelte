<script lang="ts">
  import data from "./data.js";
  import * as Sidebar from "$lib/components/ui/sidebar/index.js";
  import AppSidebar from "$lib/components/app-sidebar.svelte";
  import SiteHeader from "$lib/components/site-header.svelte";
  import SectionCards from "$lib/components/section-cards.svelte";
  import ChartAreaInteractive from "$lib/components/chart-area-interactive.svelte";
  import DataTable from "$lib/components/data-table.svelte";
  import GroupMemberTable from "$lib/components/group-member-table.svelte";
  import SelectArea from "$lib/components/select-area.svelte";
  import Choropleth from "$lib/components/choropleth.svelte"
</script>

<Sidebar.Provider
  style="--sidebar-width: calc(var(--spacing) * 64); --header-height: calc(var(--spacing) * 20);"
>
  <AppSidebar variant="inset" />
  <Sidebar.Inset>
    <SiteHeader />
    <div class="flex flex-1 flex-col">
      <div class="@container/main flex flex-1 flex-col gap-2">
        <div class="flex flex-col gap-4 py-4 md:gap-6 md:py-6 mx-4 lg:mx-6">
          <div class="">
            <p class="text-sm mb-2">Country/ Area:</p>
            <SelectArea />
          </div>
          <Choropleth />
          <SectionCards />
          <div>
            <ChartAreaInteractive />
          </div>
          <DataTable {data} />
          <div class="flex flex-col lg:w-2/3 md:w-3/4 sm:w-full mx-auto mt-10">
            <GroupMemberTable/>
          </div>
        </div>
      </div>
    </div>
    <div class="text-muted-foreground text-sm text-center bg-sidebar h-[200px] flex flex-col mx-auto w-full justify-center items-center">
      <p>Built by Kelompok 1 Mata Kuliah Komputasi Statistik Kelas 2KS1</p>
      <p>Tahun 2025</p>
    </div>
  </Sidebar.Inset>
  <div>
  </div>
</Sidebar.Provider>
