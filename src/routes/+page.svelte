<script lang="ts">
    import { onMount } from "svelte";

    const GRID_SIZE = 16;

    // It doesn't work otherwise
    import * as joint from "@joint/core";

    // import { dia, shapes } from "@joint/core";
    // import pkg from "@joint/core";
    // const { dia, shapes } = pkg;

    let paperRef: HTMLElement;

    onMount(() => {
        const namespace = joint.shapes;

        const graph = new joint.dia.Graph({}, { cellNamespace: namespace });

        const paper = new joint.dia.Paper({
            el: paperRef,
            model: graph,
            width: paperRef.clientWidth,
            height: window.innerHeight,
            background: { color: "#F5F5F5" },
            cellViewNamespace: namespace,
            gridSize: GRID_SIZE,
            drawGrid: true,
        });

        // create elements
        const rect1 = new joint.shapes.standard.Rectangle();
        rect1.position(GRID_SIZE * 2, GRID_SIZE * 3);
        rect1.resize(GRID_SIZE * 4, GRID_SIZE * 2);
        rect1.addTo(graph);

        const rect2 = new joint.shapes.standard.Rectangle();
        rect2.position(GRID_SIZE * 1, GRID_SIZE * 15);
        rect2.resize(GRID_SIZE * 6, GRID_SIZE * 2);
        rect2.addTo(graph);

        rect1.attr("body", { stroke: "#C94A46", rx: 2, ry: 2 });
        rect2.attr("body", { stroke: "#C94A46", rx: 2, ry: 2 });

        rect1.attr("label", { text: "Hello", fill: "#353535" });
        rect2.attr("label", { text: "World!", fill: "#353535" });

        // create link
        const link = new joint.shapes.standard.Link();
        link.source(rect1);
        link.target(rect2);
        link.addTo(graph);
        link.appendLabel({
            attrs: {
                text: {
                    text: "to the",
                },
            },
        });
        link.router("orthogonal");
        // link.connector("straight", { cornerType: "line" });
    });
</script>

<div class="grid grid-cols-[200px_1fr] h-full">
    <div></div>
    <div bind:this={paperRef}></div>
</div>
