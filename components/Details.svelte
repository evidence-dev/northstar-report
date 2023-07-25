<script>
    export let visible = false;
    export let title = "Details";
    import { slide } from 'svelte/transition';

</script>

<div class="mb-4 mt-3 ml-1">

<button 
    class="italic text-base text-grey-800 cursor-pointer" 
    on:click={() => (visible = !visible)}>
    <span 
        class={visible ? "marker rotate-marker" : "marker"} />
        {title}
</button>

{#if visible}
    <div 
        class="ml-3 pt-3 mb-6 text-base"
        transition:slide
    >
        <slot />
    </div>
{/if}

</div>

<style>
    .marker {
        
        border-left: 5px solid transparent;
        border-right: 5px solid transparent;
        border-top: 9px solid var(--grey-900);
        margin-right: 8px;
        transform: rotate(-90deg);
        transition: transform 0.2s ease;
    }

    .rotate-marker {
        transform: rotate(0deg);
    }

    button {
        display: flex;
        align-items: center;
        cursor: pointer;
        
    }
</style>
