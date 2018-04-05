<template>
    <base-element
            class="overlay"
            :w="315"
            :h="229"
            :x="258"
            :y="156"
            :resizable="false"
            :draggable="false"

    >
        <div class="address">
            <div>
                RECIPIENT NAME<br>
                AND ADDRESS<br>
                PRINTED HERE
            </div>
        </div>
    </base-element>
</template>

<script>
  import BaseElement from './base_element.vue';

  export default {
    name: 'address_overlay_element',
    extends: BaseElement
  }


</script>

<style>
</style>
<style scoped>

    .overlay {
        background: white;
        padding: 20px;
        width: 300px;
        height: 200px;
        user-select: none;
        outline: 2px dashed lightgray;
    }

    .address {
        position: relative;
        color: grey;
        top: 60%;
        font-size: 120%;
    }

</style>
