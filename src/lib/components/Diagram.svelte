<script lang="ts">
    const GRID_SIZE = 16;

    // It doesn't work otherwise
    import * as joint from "@joint/core";
    import { UMLClass } from "./UML/UMLClass";
    import { UMLLink } from "./UML/UMLLink";
    import { darkenHSL } from "$lib/utils/color";
    import ComponentEditor from "$lib/components/ComponentEditor.svelte";
    import { ResizeTool } from "./JointJSTools/Resize";

    // import { dia, shapes } from "@joint/core";
    // import pkg from "@joint/core";
    // const { dia, shapes } = pkg;

    let paperRef: HTMLElement;
    let paper: joint.dia.Paper | null = null;
    let graph: joint.dia.Graph | null = null;
    let selectedComponent = $state.raw<
        joint.dia.ElementView | joint.dia.LinkView | null
    >(null);
    let isTypesMenuOpen: boolean = false;

    const tools = [
        // TODO: export image?
        { icon: "select_all" },
        { icon: "serif" },
        { icon: "shape_line" },
        { icon: "arrow_and_edge" },
        { icon: "sticky_note_2" },
    ];

    let selectedTool = $state.raw(tools[0]);
    let zoomLevel: number = $state(100);

    // function resetAll(paper: joint.dia.Paper) {
    //     paper.drawBackground({
    //         color: "white",
    //     });

    //     var elements = paper.model.getElements();
    //     for (var i = 0, ii = elements.length; i < ii; i++) {
    //         var currentElement = elements[i];
    //         currentElement.attr("body/stroke", "black");
    //     }

    //     var links = paper.model.getLinks();
    //     for (var j = 0, jj = links.length; j < jj; j++) {
    //         var currentLink = links[j];
    //         currentLink.attr("line/stroke", "black");
    //         currentLink.label(0, {
    //             attrs: {
    //                 body: {
    //                     stroke: "black",
    //                 },
    //             },
    //         });
    //     }
    // }

    // this runs only onMount
    $effect(() => {
        const namespace = joint.shapes;
        graph = new joint.dia.Graph();
        paper = new joint.dia.Paper({
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
            },
        );

        paper.on("blank:pointerclick", (event, x, y) => {
            if (!graph) return;
            if (selectedComponent) {
                selectedComponent.removeTools();
                joint.highlighters.stroke.remove(
                    selectedComponent,
                    "highlight-selected",
                );
                selectedComponent = null;
                return;
            }
            const umlClass = new UMLClass();
            umlClass.position(x, y);
            umlClass.resize(GRID_SIZE * 6, GRID_SIZE * 2);
            umlClass.attr({
                body: {
                    fill: "#FFFFFF",
                    stroke: "#000000",
                    strokeWidth: 1,
                },
            });
            umlClass.addTo(graph);
        });

        paper.on("cell:pointerdblclick", (cellView: joint.dia.CellView) => {
            // prevents highliting multiple components
            if (selectedComponent) {
                joint.highlighters.stroke.remove(
                    selectedComponent,
                    "highlight-selected",
                );
            }
            // for some reasons, cellView.mode.isElement() does not type restrict, so typescript needs this
            const cellViewIsElementView =
                cellView instanceof joint.dia.ElementView;
            if (
                cellViewIsElementView ||
                cellView instanceof joint.dia.LinkView
            ) {
                selectedComponent = cellView;
                if (cellViewIsElementView) {
                    cellView.addTools(
                        new joint.dia.ToolsView({
                            tools: [
                                new ResizeTool({
                                    selector: "body",
                                }),
                            ],
                        }),
                    );
                }
            } else return;
            joint.highlighters.stroke.add(
                cellView,
                cellViewIsElementView
                    ? { selector: "body" }
                    : { selector: "line" },
                "highlight-selected",
                {
                    padding: cellViewIsElementView ? 6 : 0,
                    layer: cellViewIsElementView ? null : "back", // "back" prevents the highlighter to cover the link
                    attrs: {
                        stroke: cellViewIsElementView
                            ? darkenHSL(cellView.model.attr("body/stroke"))
                            : darkenHSL(cellView.model.attr("line/stroke")),
                        "stroke-width": cellViewIsElementView ? 3 : 12,
                    },
                },
            );
        });

        let isPanning = $state.raw(false);

        paper.on({
            "blank:pointerdown": (evt, x, y) => {
                evt.preventDefault();
                evt.stopPropagation();
                isPanning = true;
                evt.data = { x, y };
            },
            "blank:pointermove cell:pointermove": (evt) => {
                if(!isPanning) return;
                // this is a joint.dia.Event as long as isPanning = true
                evt.preventDefault();
                evt.stopPropagation();
                if(!paper) return;
                const currentPoint = paper.clientToLocalPoint(evt.clientX ?? 0, evt.clientY ?? 0);
                const dx = (currentPoint.x ?? 0) - evt.data.x;
                const dy = (currentPoint.y ?? 0) - evt.data.y;
                
                const translate = paper.translate();
                paper.translate(translate.tx + dx, translate.ty + dy);
            },
            "blank:pointerup cell:pointerup": (evt) => {
                // this is a joint.dia.Event as long as isPanning = true
                if(!isPanning) return;
                evt.preventDefault();
                isPanning = false;
            }
        });

        // create elements
        const class1 = new UMLClass();
        class1.position(GRID_SIZE * 50, GRID_SIZE * 10);
        class1.resize(GRID_SIZE * 6, GRID_SIZE * 2);
        class1.set("name", "Hello");
        class1.set("attributesList", [
            "attr1: Data",
            "attr2: DataOra",
            "attr3: DataOra",
        ]);
        class1.set("operationsList", ["-op1(args): void"]);
        class1.addTo(graph);

        const class2 = new UMLClass();
        class2.position(GRID_SIZE * 50, GRID_SIZE * 25);
        class2.resize(GRID_SIZE * 6, GRID_SIZE * 2);
        class2.set("name", "World");
        class2.set("attributesList", [
            "attr1: Periodo",
            "attr2: FasciaOraria",
            "attr3: GiornoSettimana",
        ]);
        class2.addTo(graph);

        class1.attr("body", { stroke: "hsl(2, 55%, 53%)", rx: 2, ry: 2 });
        class2.attr("body", { stroke: "hsl(2, 55%, 53%)", rx: 2, ry: 2 });

        class1.attr("label", { fill: "hsl(0, 0%, 21%)" });
        class2.attr("label", { fill: "hsl(0, 0%, 21%)" });

        const link = new UMLLink();
        link.source(class1);
        link.target(class2);

        link.set({
            sourceMultiplicity: "1",
            name: "to the",
            targetMultiplicity: "0..*",
        });

        link.router("manhattan");
        link.addTo(graph);

        return () => {
            if (paper) {
                paper.remove();
                paper = null;
            }
        };
    });

    $effect(() => {
        // svelte does not recognize zoomLevel as a effect dependency otherwise
        const _ = zoomLevel;
        if (!paper) return;

        paper.scale(zoomLevel / 100);
    });
</script>

<div>
    <div class="relative">
        <div bind:this={paperRef}></div>

        {#if selectedComponent}
            <div class="absolute top-10 left-10 bg-red-500 w-[200px] h-4/5">
                <ComponentEditor component={selectedComponent.model} />
            </div>
        {/if}

        <div class="absolute bottom-10 left-10 flex gap-5 items-center">
            <div class="flex items-center gap-3 bg-white px-3 py-2 card">
                <button
                    class="material-symbols-outlined"
                    onclick={(e) => {
                        e.preventDefault();
                        zoomLevel -= 10;
                    }}
                >
                    zoom_out
                </button>
                <input type="number" bind:value={zoomLevel} class="w-20" />
                <button
                    class="material-symbols-outlined"
                    onclick={(e) => {
                        e.preventDefault();
                        zoomLevel += 10;
                    }}
                >
                    zoom_in
                </button>
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
