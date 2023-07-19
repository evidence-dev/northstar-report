<!-- Mermaid.svelte -->
<script>
    import { onMount, createEventDispatcher } from "svelte";
    import mermaid from "mermaid";
    export let id;

    const dispatch = createEventDispatcher();

    onMount(() => {
        if (!id) {
            this.error(new Error("The 'id' prop is required for the Mermaid component."));
            return;
        }

        mermaid.initialize({
            startOnLoad: true, // Auto-render diagrams when the page loads
            theme: "default", // Theme for the diagram, "base" is customizable https://mermaid.js.org/config/theming.html
        });
        mermaid.init(undefined, document.getElementById(`mermaid-container-${id}`));

        // Dispatch an event to let the parent component know that the diagram is rendered
        dispatch("mermaidRendered");
    });
</script>

<div id={`mermaid-container-${id}`} class={`mermaid-container-${id}`}>
    <slot />
</div>
