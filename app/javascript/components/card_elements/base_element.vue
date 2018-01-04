<template>
</template>

<script>
  import VueDraggableResizable from './vue-draggable-resizable';

  export default {
    name: 'base_element',
    // data: function() { return {} }
    components:{
      'base-element': VueDraggableResizable
    },
  };

</script>

<style scoped>
</style>

<style>
  .vdr .handle {
    box-sizing: border-box;
    display: none;
    position: absolute;
    width: 10px; /* */
    height: 10px; /* */
    border-radius: 5px; /* */
    font-size: 1px;
    background: #333333; /* #EEE; */
    border: 1px solid white;
  }

  .vdr .handle-tl {
    top: -5px;
    left: -5px;
    cursor: nwse-resize;
  }

  .vdr .handle-tm {
    top: -5px;
    left: 50%;
    margin-left: -5px;
    cursor: ns-resize;
  }

  .vdr .handle-tr {
    top: -5px;
    right: -5px;
    cursor: nesw-resize;
  }

  .vdr .handle-tl {
    top: -5px;
    left: -5px;
    cursor: nw-resize;
  }
  .vdr .handle-tm {
    top: -5px;
    left: 50%;
    margin-left: -5px;
    cursor: n-resize;
  }
  .vdr .handle-tr {
    top: -5px;
    right: -5px;
    cursor: ne-resize;
  }
  .vdr .handle-ml {
    top: 50%;
    margin-top: -5px;
    left: -5px;
    cursor: w-resize;
  }
  .vdr .handle-mr {
    top: 50%;
    margin-top: -5px;
    right: -5px;
    cursor: e-resize;
  }
  .vdr .handle-bl {
    bottom: -5px;
    left: -5px;
    cursor: sw-resize;
  }
  .vdr .handle-bm {
    bottom: -5px;
    left: 50%;
    margin-left: -5px;
    cursor: s-resize;
  }
  .vdr .handle-br {
    bottom: -5px;
    right: -5px;
    cursor: se-resize;
  }

</style>
