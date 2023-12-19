<!-- Mermaid.svelte -->
<script context="module">
    import mermaid from "mermaid";
</script>

<script>
    import { onMount, createEventDispatcher } from "svelte";
    export let id;

    let config = {
        startOnLoad: true,
        theme: "base",
        themeVariables: {
            primaryColor: "hsla(207, 65%, 39%, 1)",
            primaryTextColor: "#fff",
            primaryBorderColor: "#fff",
            lineColor: "hsla(195, 49%, 51%, 1)",
            secondaryColor: "hsla(342, 40%, 40%, 1)"
        }
    }

    const dispatch = createEventDispatcher();

    onMount(() => {
        if (!id) {
            throw new Error("The 'id' prop is required for the Mermaid component.");
        }

        mermaid.init(
            config,
            document.getElementById(`mermaid-container-${id}`)
        );

        // Dispatch an event to let the parent component know that the diagram is rendered
        dispatch("mermaidRendered");
    });
</script>

<div id={`mermaid-container-${id}`} class={`mermaid-container-${id} pb-4`}>
    <slot />
</div>