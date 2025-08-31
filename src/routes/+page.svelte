<script lang="ts">
    import { onMount } from "svelte";

    const GRID_SIZE = 16;

    // It doesn't work otherwise
    import * as joint from "@joint/core";
    import ClassEditor from "$lib/components/ClassEditor.svelte";

    // import { dia, shapes } from "@joint/core";
    // import pkg from "@joint/core";
    // const { dia, shapes } = pkg;

    let paperRef: HTMLElement;
    let selectedComponent: joint.dia.Element | null = null;
    let isTypesMenuOpen: boolean = false;

    type Tool = {
        icon: string;
    };

    const tools: Tool[] = [
        // TODO: export image?
        { icon: "select_all" },
        { icon: "serif" },
        { icon: "shape_line" },
        { icon: "arrow_and_edge" },
        { icon: "sticky_note_2" },
    ];

    let selectedTool = tools[0];
    let zoomLevel: number = 100;

    onMount(() => {
        const namespace = joint.shapes;

        const graph = new joint.dia.Graph({}, { cellNamespace: namespace });

        // TODO: on window size change, update the paper size to match it

        const paper = new joint.dia.Paper({
            el: paperRef,
            model: graph,
            width: paperRef.clientWidth,
            height: window.innerHeight,
            background: { color: "white" },
            cellViewNamespace: namespace,
            gridSize: GRID_SIZE,
            drawGrid: true,
        });

        // https://resources.jointjs.com/docs/jointjs/v4.0/joint.html#dia.Paper.events
        paper.on("blank:pointerdblclick", function (this: joint.dia.Paper) {
            this.drawBackground({
                color: "white",
            });
        });

        paper.on(
            "blank:mousewheel",
            (event: joint.dia.Event, x: number, y: number, delta: number) => {
                // console.log(event.originalEvent.deltaY);
                // let delta = event.originalEvent.deltaY;
                // if (delta > 0) zoomLevel -= 10;
                // else zoomLevel += 10;
                // this.scale(zoomLevel / 100);
                event.preventDefault();
                if (delta > 0) zoomLevel += 10;
                else zoomLevel -= 10;
                paper.scale(zoomLevel / 100);
            },
        );

        paper.on("blank:pointerclick", (event: joint.dia.Event) => {
            if (selectedComponent) {
                selectedComponent = null;
                return;
            }
            // Convert client coords to paper-local coords
            const localPoint = paper.clientToLocalPoint(
                event.clientX || 0,
                event.clientY || 0,
            );

            const rect1 = new joint.shapes.standard.Rectangle();
            rect1.position(localPoint.x, localPoint.y);
            rect1.resize(GRID_SIZE * 4, GRID_SIZE * 2);
            rect1.attr({
                body: {
                    fill: "#FFFFFF",
                    stroke: "#000000",
                    strokeWidth: 1,
                },
            });
            rect1.addTo(graph);
        });

        paper.on("element:pointerdblclick", function (elementView) {
            var currentElement = elementView.model;
            currentElement.attr("body/stroke", "orange");
            selectedComponent = currentElement;
        });

        paper.on("link:pointerdblclick", function (linkView) {
            var currentLink = linkView.model;
            currentLink.attr("line/stroke", "orange");
            currentLink.label(0, {
                attrs: {
                    body: {
                        stroke: "orange",
                    },
                },
            });
        });

        paper.on(
            "cell:pointerdblclick",
            function (this: joint.dia.Paper, cellView) {
                var isElement = cellView.model.isElement();
                var message = (isElement ? "Element" : "Link") + " clicked";
                resetAll(this);
            },
        );

        function resetAll(paper: joint.dia.Paper) {
            paper.drawBackground({
                color: "white",
            });

            var elements = paper.model.getElements();
            for (var i = 0, ii = elements.length; i < ii; i++) {
                var currentElement = elements[i];
                currentElement.attr("body/stroke", "black");
            }

            var links = paper.model.getLinks();
            for (var j = 0, jj = links.length; j < jj; j++) {
                var currentLink = links[j];
                currentLink.attr("line/stroke", "black");
                currentLink.label(0, {
                    attrs: {
                        body: {
                            stroke: "black",
                        },
                    },
                });
            }
        }

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
        link.attr({
            line: {
                stroke: "#333333",
                strokeWidth: 2,
                targetMarker: {
                    type: "none", // You can also use { d: 'M 0 0' }
                },
            },
        });
        link.label(0, {
            attrs: {
                text: {
                    text: "to the",
                },
            },
        });
        link.router("orthogonal");
        link.connector("straight", { cornerType: "line" });
        link.addTo(graph);
    });
</script>

<div>
    <div class="relative">
        <div bind:this={paperRef}></div>

        {#if selectedComponent}
            <div class="absolute top-10 left-10 bg-red-500 w-[200px] h-4/5">
                panel
            </div>
        {/if}

        <div class="absolute bottom-10 left-10 flex gap-5 items-center">
            <div class="flex items-center gap-3 bg-white px-3 py-2 card">
                <button class="material-symbols-outlined"> zoom_out </button>
                <input type="number" bind:value={zoomLevel} class="w-20" />
                <button class="material-symbols-outlined"> zoom_in </button>
            </div>
            <!-- TODO: stack for changes -->
            <!-- TODO: disable undo if stack is empty -->
            <!-- TODO: disable redo current index not in stack len (somehow) -->
            <div class="flex items-center gap-3 bg-white px-3 py-2 card">
                <button class="material-symbols-outlined"> undo </button>
                <button disabled class="material-symbols-outlined">
                    redo
                </button>
            </div>
        </div>

        <div
            class="absolute right-10 bottom-10 bg-white w-10 h-10 grid place-items-center card"
        >
            <span class="material-symbols-outlined"> help </span>
        </div>

        <div
            class="absolute top-10 left-1/2 -translate-x-1/2 flex gap-5 bg-white px-4 py-3 card"
        >
            {#each tools as tool}
                <button
                    class="material-symbols-outlined"
                    class:bg-stone-100={selectedTool == tool}
                    onclick={() => (selectedTool = tool)}
                >
                    {tool.icon}
                </button>
            {/each}
            <!-- <button class="material-symbols-outlined"> serif </button> -->
            <!-- <button class="material-symbols-outlined"> shape_line </button> -->
            <!-- <button class="material-symbols-outlined"> arrow_and_edge </button> -->
            <!-- <button class="material-symbols-outlined"> sticky_note_2 </button> -->
        </div>
    </div>

    {#if isTypesMenuOpen}
        <div class="absolute right-0 top-0 w-72 bg-white h-full">types</div>
    {/if}
</div>
