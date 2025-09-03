<script lang="ts">
    import * as joint from "@joint/core";
    import { darkenHSL, getBorderColor } from "$lib/utils/color";

    const { component }: { component: joint.dia.Element | joint.dia.Link } =
        $props();
    let componentIsElement = component instanceof joint.dia.Element;
    let name: string = $state(component.get("name") || "");
    let attributes: string[] = $state.raw(
        component.get("attributesList") || [],
    );
    let operations: string[] = $state.raw(
        component.get("operationsList") || [],
    );

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

        component.attr("body/fill", color);
    };

    const changeStrokeColor = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        color: string,
    ) => {
        e.preventDefault();

        if (component instanceof joint.dia.ElementView)
            component.attr("body/stroke", darkenHSL(color));
        else component.attr("line/stroke", color);
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

        if (componentIsElement) component.attr("body/strokeDasharray", style);
        else component.attr("line/strokeDasharray", style);
    };

    const changeStrokeWidth = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
        strokeWidth: number,
    ) => {
        e.preventDefault();

        if (componentIsElement) component.attr("body/strokeWidth", strokeWidth);
        else component.attr("line/strokeWidth", strokeWidth + 1);
    };

    const changeName = (
        e: Event & { currentTarget: EventTarget & HTMLInputElement },
    ) => {
        e.preventDefault();
        // for some reasons, jointjs needs type narrowing here
        if (component instanceof joint.dia.Link) component.set("name", name);
        else component.set("name", name);
    };

    const addAttribute = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
    ) => {
        e.preventDefault();

        if (component instanceof joint.dia.Link) return;
        attributes = [...attributes, "-attr: Prova"];
        component.set("attributesList", attributes);
    };

    const addOperation = (
        e: MouseEvent & { currentTarget: EventTarget & HTMLButtonElement },
    ) => {
        e.preventDefault();
        if (component instanceof joint.dia.Link) return;

        operations = [...operations, "-op(args): void"];
        component.set("operationsList", operations);
    };
</script>

<div class="p-4">
    <div>
        {#if componentIsElement}
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
        {/if}
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
        {#if componentIsElement}
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
        {/if}
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
        <h3 class="text-xl text-center">
            {component instanceof joint.dia.Element ? "Class" : "Association"}
        </h3>
        <h4>Name</h4>
        <input
            type="text"
            bind:value={name}
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
            oninput={(e) => changeName(e)}
        />
        {#if componentIsElement}
            <button class="cursor-pointer" onclick={(e) => addAttribute(e)}>
                + add attribute
            </button>
            <button class="cursor-pointer" onclick={(e) => addOperation(e)}>
                + add operation
            </button>
        {/if}
    </div>
</div>
