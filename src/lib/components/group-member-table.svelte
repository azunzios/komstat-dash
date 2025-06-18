<script lang="ts">
    import * as Table from "$lib/components/ui/table/index.js";
    import * as Avatar from "$lib/components/ui/avatar/index.js";
    import { Badge } from "$lib/components/ui/badge/index.js";
</script>

<h1 class="text-muted-foreground mt-4 text-sm">Anggota Kelompok 1</h1>

<Table.Root class="w-full" id="group-member">
    <Table.Body class="gap-0">
        <Table.Row>
            <Table.Cell class="font-medium w-6">
            <Avatar.Root>
                <Avatar.Fallback>AL</Avatar.Fallback>
            </Avatar.Root></Table.Cell>
            <Table.Cell class="font-medium"
                >Alif Zakiansyah As Syauqi</Table.Cell>
            <Table.Cell class="w-6"><Badge class="text-white">222313288</Badge></Table.Cell>
            <Table.Cell class="w-6 text-right"><Badge variant=outline>2KS1</Badge></Table.Cell>
        </Table.Row>
        <Table.Row>
            <Table.Cell class="font-medium">
                <Avatar.Root>
                    <Avatar.Fallback>MO</Avatar.Fallback>
                </Avatar.Root></Table.Cell>
            <Table.Cell class="font-medium">Moses</Table.Cell>
            <Table.Cell><Badge class="text-white">222313288</Badge></Table.Cell>
            <Table.Cell class="text-right"><Badge variant=outline>2KS1</Badge></Table.Cell>
        </Table.Row>
        <Table.Row>
            <Table.Cell class="font-medium">
                <Avatar.Root>
                    <Avatar.Fallback>NR</Avatar.Fallback>
                </Avatar.Root></Table.Cell>
            <Table.Cell class="font-medium"> Narangga Khoirul Utama
            </Table.Cell>
            <Table.Cell><Badge class="text-white">222313288</Badge></Table.Cell>
            <Table.Cell class="text-right"><Badge variant=outline>2KS1</Badge></Table.Cell>
        </Table.Row>
    </Table.Body>
</Table.Root>
