<template>
    <base-element
            class="overlay"
            :w="300"
            :h="200"
            :x="100"
            :y="100"
            :resizable="false"
            :draggable="false"

    >
        <div>HELLO</div>
    </base-element>
</template>

<script>
</script>

<style>
</style>
<style scoped>

    .overlay {
        background: lightsalmon;

        position: absolute;
        /*text-align: center;*/

        width: 300px;
        height: 200px;
        font-family: 'Montserrat';
        user-select: none;
    }


</style>
