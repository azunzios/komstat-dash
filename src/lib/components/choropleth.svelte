<script lang="ts">
  import { Badge } from "$lib/components/ui/badge/index.js";
  import * as Select from "$lib/components/ui/select/index.js";
  import { Slider }  from  "$lib/components/ui/slider/index.js";
  import { onMount } from 'svelte';
  import type { Map } from 'leaflet';
  import * as Card from "$lib/components/ui/card/index.js";
  import 'leaflet/dist/leaflet.css';


  let year = $state(2023);
 
  // Hapus import * as L from 'leaflet'; di sini.
  // Leaflet akan diimpor secara dinamis di dalam onMount.

  const gasTypeOptions = [
    { gasType: "total", label: "Total" },
    { gasType: "co2", label: "CO2" },
    { gasType: "n2o", label: "N2O" },
    { gasType: "ch4", label: "CH4" },
  ];
  
  let gasType = $state("total");
  let { gasType: _gasType = $bindable() } = $props();

  const triggerContent = $derived(
    gasTypeOptions.find((f)=>f.gasType==gasType)?.label ?? "Select gas type"
  );

  let map: Map;
  let mapContainer: HTMLElement;
  let geoJsonLayer: any; // Add this to store the GeoJSON layer reference
  
  // Data akan dipetakan berdasarkan nama negara (misal: "Indonesia": 513)
  let countryData: Record<string, number> = {};
  let minGHGValue = 0; // Nilai minimum emisi GRK untuk skala warna
  let maxGHGValue = 0; // Nilai maksimum emisi GRK untuk skala warna

  /**
   * Menginterpolasi warna secara linier antara dua warna.
   * @param color1 Warna awal (contoh: '#RRGGBB').
   * @param color2 Warna akhir (contoh: '#RRGGBB').
   * @param factor Faktor interpolasi (0.0 hingga 1.0).
   * @returns String warna hasil interpolasi.
   */
  function interpolateColor(color1: string, color2: string, factor: number): string {
      // Mengubah heksadesimal ke komponen RGB
      const result = color1.slice(1).match(/.{2}/g)?.map(h => parseInt(h, 16));
      const target = color2.slice(1).match(/.{2}/g)?.map(h => parseInt(h, 16));

      if (!result || !target) return color1; // Fallback jika parsing gagal

      // Interpolasi setiap komponen RGB
      for (let i = 0; i < 3; i++) {
          result[i] = Math.round(result[i] + factor * (target[i] - result[i]));
      }
      // Mengubah kembali komponen RGB ke heksadesimal
      return '#' + result.map(c => c.toString(16).padStart(2, '0')).join('');
  }

  /**
   * Mendapatkan warna berdasarkan nilai emisi GRK dengan gradasi.
   * Warna akan diinterpolasi antara 'kuning muda' dan 'merah tua'
   * berdasarkan posisi nilai dalam rentang minGHGValue hingga maxGHGValue.
   * @param value Nilai emisi GRK negara.
   * @returns String warna heksadesimal.
   */
  function getColor(value: number): string {
    const startColor = '#ffeda0'; // Kuning lebih terang
    const endColor = '#800026';   // Merah lebih gelap

    if (maxGHGValue === minGHGValue) {
      return startColor;
    }

    const normalizedValue = (value - minGHGValue) / (maxGHGValue - minGHGValue);
    const clampedNormalizedValue = Math.max(0, Math.min(1, normalizedValue));
    return interpolateColor(startColor, endColor, clampedNormalizedValue);
  }

  /**
   * Mengambil nilai emisi GRK dengan aman berdasarkan nama negara.
   * @param countryCode Nama negara (misalnya: IDN)
   * @returns Nilai emisi GRK, atau 0 jika tidak ditemukan atau tidak valid.
   */
  function getCountryValue(countryCode: string, year: any, type: string): number {
      if (!countryCode) return 0;
      const countryObj = (countryData as any)[countryCode];
      if (!year) return countryObj || {};
      // Mencari nilai berdasarkan nama negara di countryData
      return countryObj?.[year][type] ?? 0;
  }
  
  function getMinMaxGHG (data: object, year:number, gas:string) : object
          {
            const values = Object
            .values(data)
            .map(country => country[year]?.[gas] ?? 0)
            .filter(v => typeof v == "number");

            if (values.length === 0 ) return {min:0, max:0};

            return {
              min: Math.min(...values),
              max: Math.max(...values)
            };
          }

  // Function to generate legend
  function generateLegend() {
    const grades = [0, 0.2, 0.4, 0.6, 0.8, 1];
    const labels = [];
    
    for (let i = 0; i < grades.length; i++) {
      const value = minGHGValue + (maxGHGValue - minGHGValue) * grades[i];
      const color = getColor(value);
      labels.push({
        color,
        value: Math.round(value).toLocaleString()
      });
    }
    
    return labels;
  }

  let legendLabels = $state(generateLegend());

  // Function to update map colors
  function updateMapColors() {
    if (!geoJsonLayer) return;
    
    const minMax = getMinMaxGHG(countryData, year, gasType);
    minGHGValue = (minMax as { min: number, max: number }).min;
    maxGHGValue = (minMax as { min: number, max: number }).max;

    // Update legend
    legendLabels = generateLegend();

    geoJsonLayer.setStyle((feature: any) => {
      const code = feature.properties?.["ISO3166-1-Alpha-3"];
      const val = getCountryValue(code, year, gasType);
      return {
        fillColor: getColor(val),
        weight: 1,
        opacity: 1,
        color: 'white',
        fillOpacity: 0.8 // Increased opacity
      };
    });

    // Update popup content for all layers
    geoJsonLayer.eachLayer((layer: any) => {
      const feature = layer.feature;
      const name = feature.properties?.name;
      const code = feature.properties?.["ISO3166-1-Alpha-3"];
      const val = getCountryValue(code, year, gasType);

      const content = `
        <b>${name || 'N/A'}</b><br>
        Kode ISO: ${code || 'N/A'}<br>
        Emisi GRK: ${val ? val.toLocaleString() + ' Mt CO₂' : 'N/A'}
      `;

      layer.setPopupContent(content);
    });
  }

  // Function to fetch and update data
  async function fetchAndUpdateData() {
    try {
      const resp = await fetch('http://localhost:8000/global-complete-data.json');
      const ghData: Record<string, number> = await resp.json();
      countryData = ghData;
      updateMapColors();
    } catch (error) {
      console.error('Gagal mengambil data emisi greenhouse:', error);
    }
  }

  // Make data fetching reactive to year and gasType changes
  $effect(() => {
    if (map && geoJsonLayer) {
      fetchAndUpdateData();
    }
  });

  onMount(async () => {
    // Initialize map
    const L = await import('leaflet');
    
    if (typeof L === 'undefined') {
      console.error('Leaflet failed to load');
      return;
    }

    map = L.map(mapContainer, {
      zoomControl: false,
      minZoom: 1.5,
      maxZoom: 1.5,
      dragging: true,
      touchZoom: false,
      scrollWheelZoom: false,
      doubleClickZoom: false,
      boxZoom: false,
      keyboard: false,
    }).setView([-5, 0], 1.5);

    // Load GeoJSON
    try {
      const geoResp = await fetch('http://localhost:8000/countries.geojson');
      const geo = await geoResp.json();

      geoJsonLayer = L.geoJson(geo, {
        style: (feature: any) => {
          const code = feature.properties?.["ISO3166-1-Alpha-3"];
          const val = getCountryValue(code, year, gasType);
          return {
            fillColor: getColor(val),
            weight: 1,
            opacity: 1,
            color: 'white',
            fillOpacity: 0.7
          };
        },
        onEachFeature: (feature, layer) => {
          const name = feature.properties?.name;
          const code = feature.properties?.["ISO3166-1-Alpha-3"];
          const val = getCountryValue(code, year, gasType);

          const content =
          `
            <b>${name || 'N/A'}</b><br>
            Kode ISO: ${code || 'N/A'}<br>
            Emisi GRK: ${val ? val.toLocaleString() + ' Mt CO₂' : 'N/A'}
          `

          layer.bindPopup(content, {
            autoPan: false,
            closeButton: true
          });
          layer.on({
            mouseover: e => {
              e.target.setStyle({ weight: 1, color: '#666', fillOpacity: 0.9 });
            },
            mouseout: e => {
              e.target.setStyle({ weight: 0.5, color: 'white', fillOpacity: 0.7 });
            }
          });
        }
      }).addTo(map);

      // Initial data fetch
      await fetchAndUpdateData();
    } catch (error) {
      console.error('Gagal memuat GeoJSON atau memproses peta:', error);
    }
  });
</script>

<svelte:head>
  <!-- Memuat stylesheet Leaflet dari CDN -->
  <link
    rel="stylesheet"
    href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
    integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
    crossorigin=""
  />
</svelte:head>

<style>
  /* Gaya global untuk body untuk menghapus margin dan padding default */
  :global(body) {
    margin: 0;
    padding: 0;
  }
  
  /* Add styles for legend */
  :global(.legend) {
    line-height: 18px;
    color: #555;
  }
  
  :global(.legend i) {
    width: 18px;
    height: 18px;
    float: left;
    margin-right: 8px;
    opacity: 0.8;
  }
</style>

<Select.Root type="single" name="selectGasType" value={gasType} onValueChange={(value) => {
  gasType = value;
  if (map && geoJsonLayer) {
    fetchAndUpdateData();
  }
}}>
  <Select.Trigger class="w-[180px] my-0">
    {triggerContent}
  </Select.Trigger>
  <Select.Content>
    <Select.Group>
      <Select.Label>Gas Types</Select.Label>
      {#each gasTypeOptions as gt (gt.gasType)}
        <Select.Item
          value={gt.gasType}
          label={gt.label}
        >
          {gt.label}
        </Select.Item>
      {/each}
    </Select.Group>
  </Select.Content>
</Select.Root>

<Card.Root class="w-full sm: h-[550px]">
  <Card.Header>
    <Card.Title>Showing Global Maps of <Badge variant="outline"> {gasType.charAt(0).toUpperCase()+gasType.slice(1)}</Badge> Green House Gas in <Badge variant="outline">{year}</Badge></Card.Title>
  </Card.Header>
  <div class="mx-6 my-0 p-0 flex flex-row text-white">
    <Slider
      type="single"
      orientation="horizontal"
      bind:value={year}
      min={1970}
      max={2023}
      step={1}
      class="mx-auto"
      onValueChange={() => {
        if (map && geoJsonLayer) {
          fetchAndUpdateData();
        }
      }}
    />
  </div>
  <Card.Content class="h-full flex flex-col p-4">
    <div class="relative w-full h-[400px]">
      <div
        bind:this={mapContainer}
        id="map"
        class="w-full h-full"
      ></div>
      
      <!-- Legend -->
      <div class="absolute bottom-4 right-4 bg-white p-2 rounded shadow-lg z-[1000]">
        <div class="text-sm font-semibold mb-1">Emisi GRK (Mt CO₂)</div>
        {#each legendLabels as label, i}
          <div class="flex items-center gap-2 mb-1">
            <div class="w-4 h-4" style="background-color: {label.color}"></div>
            <span class="text-xs">{label.value}</span>
          </div>
        {/each}
      </div>
    </div>
  </Card.Content>
</Card.Root>