<script lang="ts">
    import * as joint from "@joint/core";
    import { darkenHSL, getBorderColor } from "$lib/utils/color";

    const { element }: { element: joint.dia.Element } = $props();
    let className: string = $state(element.get("name") || "");
    let attributes: string[] = $state.raw(element.get("attributesList") || []);
    let operations: string[] = $state.raw(element.get("operationsList") || []);

    const strokeFills = [
        { color: "hsl(0,0%,100%)" },
        { color: "hsl(280,27%,87%)" },
        { color: "hsl(215,85%,92%)" },
        { color: "hsl(117,30%,87%)" },
        { color: "hsl(31,100%,90%)" },
        { color: "hsl(45,100%,90%)" },
        { color: "hsl(3,76%,89%)" },
    ];

    const strokes: { color: string }[] = JSON.parse(
        JSON.stringify(strokeFills),
    );

    const fillStyles = [{ value: "default" }];

    const strokeStyles = [
        { name: "Solid Thick", value: "0" },
        { name: "Dashed", value: "8 8" },
        { name: "Long Dashed", value: "15 5" },
        { name: "Dense Dashed", value: "20 2" },
        { name: "Dotted", value: "2 5" },
        { name: "Sparse Dotted", value: "2 10" },
    ];

    const strokeWidths = [
        { value: 1 },
        { value: 3 },
        { value: 5 },
        { value: 7 },
    ];

    const changeFillColor = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        color: string,
    ) => {
        e.preventDefault();

        element.attr("body/fill", color);
    };

    const changeStrokeColor = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        color: string,
    ) => {
        e.preventDefault();

        element.attr("body/stroke", darkenHSL(color));
    };

    const changeFillStyle = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        style: string,
    ) => {
        e.preventDefault();

        return;
    };

    const changeStrokeStyle = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        style: string,
    ) => {
        e.preventDefault();

        element.attr("body/strokeDasharray", style);
    };

    const changeStrokeWidth = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        strokeWidth: number,
    ) => {
        e.preventDefault();

        element.attr("body/strokeWidth", strokeWidth);
    };

    const changeClassName = (
        e: Event & { currentTarget: EventTarget & HTMLInputElement },
    ) => {
        e.preventDefault();

        element.set("name", className);
    };

    const addAttribute = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
    ) => {
        e.preventDefault();

        attributes = [...attributes, "-attr: Prova"];
        element.set("attributesList", attributes);
    }

    const addOperation = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
    ) => {
        e.preventDefault();

        operations = [...operations, "-op(args): void"];
        element.set("operationsList", operations);
    }
</script>

<div class="p-4">
    <div>
        <p>Fill</p>
        <div class="flex-[1_1_100%]">
            {#each strokeFills as strokeFill, i}
                <button
                    class={`min-w-4 min-h-4 mx-1 first:ml-0 last:mr-0 cursor-pointer`}
                    style={`background-color: ${strokeFill.color}; border: solid 2px ${getBorderColor(strokeFill.color)};`}
                    aria-label={`stroke-${i}`}
                    onclick={(e) => changeFillColor(e, strokeFill.color)}
                >
                </button>
            {/each}
        </div>
        <p>Stroke</p>
        <div class="flex-[1_1_100%]">
            {#each strokes as stroke, i}
                <button
                    class={`min-w-4 min-h-4 mx-1 first:ml-0 last:mr-0 cursor-pointer`}
                    style={`background-color: ${stroke.color}; border: solid 2px ${getBorderColor(stroke.color)};`}
                    aria-label={`stroke-${i}`}
                    onclick={(e) => changeStrokeColor(e, stroke.color)}
                >
                </button>
            {/each}
        </div>
        <p>Fill style</p>
        <div class="flex-[1_1_100%]">
            {#each fillStyles as fillStyle, i}
                <button
                    class={`min-w-4 min-h-4 mx-1 first:ml-0 last:mr-0 bg-white cursor-pointer`}
                    aria-label={`fillStyle-${i}`}
                    onclick={(e) => changeFillStyle(e, fillStyle.value)}
                >
                </button>
            {/each}
        </div>
        <p>Stroke style</p>
        <div class="flex-[1_1_100%]">
            {#each strokeStyles as strokeStyle, i}
                <button
                    class="max-w-4 max-h-4 mx-1 first:ml-0 last:mr-0 bg-white cursor-pointer"
                    aria-label={`strokeStyle-${i}`}
                    onclick={(e) => changeStrokeStyle(e, strokeStyle.value)}
                >
                    <svg
                        width="100%"
                        height="100%"
                        viewBox="0 0 24 24"
                        preserveAspectRatio="none"
                    >
                        <rect
                            x="1"
                            y="1"
                            width="22"
                            height="22"
                            fill="none"
                            stroke="black"
                            stroke-width="2"
                            stroke-dasharray={strokeStyle.value}
                            stroke-linecap={strokeStyle.name
                                .toLowerCase()
                                .includes("dotted")
                                ? "round"
                                : "butt"}
                        />
                    </svg>
                </button>
            {/each}
        </div>
        <p>Stroke width</p>
        <div class="flex-[1_1_100%]">
            {#each strokeWidths as strokeWidth, i}
                <button
                    class={`min-w-4 min-h-4 mx-1 first:ml-0 last:mr-0 bg-white cursor-pointer`}
                    style={`outline: ${strokeWidth.value / 1.5}px solid black; outline-offset: -${strokeWidth.value / 2}px;`}
                    aria-label={`strokeWidth-${i}`}
                    onclick={(e) => changeStrokeWidth(e, strokeWidth.value)}
                >
                </button>
            {/each}
        </div>
    </div>
    <div>
        <h3 class="text-xl text-center">Class</h3>
        <h4>Name</h4>
        <input
            type="text"
            bind:value={className}
            class="
                w-full
                rounded-md

                bg-white
                text-gray-900
                p-1
                border border-gray-300
                
                focus:outline-none
                focus:border-transparent
                focus:ring-2
                focus:ring-blue-500

                transition
            "
            onchange={(e) => changeClassName(e)}
        />
        <button class="cursor-pointer" onclick={(e) => addAttribute(e)}> + add attribute </button>
        <button class="cursor-pointer" onclick={(e) => addOperation(e)}>+ add operation</button>
    </div>
</div>
