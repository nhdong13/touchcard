<template>
   <vue-draggable-resizable
       class="card-element"
       v-on:dragging="onDrag"
       :parent="true"
   >
  </vue-draggable-resizable>
</template>

<script>
  import VueDraggableResizable from 'vue-draggable-resizable';

  export default {
    data: function () {
      return {
        // width: 0,
        // height: 0,
        x: 0,
        y: 0
      }
    },
    methods: {
      // onResize: function (x, y, width, height) {
      //   this.x = x
      //   this.y = y
      //   this.width = width
      //   this.height = height
      // },
      onDrag: function (x, y) {
        this.x = x
        this.y = y
      }
    },
    components: {
      'vue-draggable-resizable': VueDraggableResizable
    }
    // mixins: [VueDraggableResizable],
  }
</script>

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
    border: 0;
    border: 1px solid white;
    transform: scale(5.0);
  }

  .vdr .handle-tl {
    top: -5px;
    left: -5px;
    cursor: nwse-resize;
    transform: scale(5.0);
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
