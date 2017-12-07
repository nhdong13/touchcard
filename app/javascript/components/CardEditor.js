import { fabric }from 'fabric-browseronly'

// import 'stylesheets/styles/automations'


// function resizeCanvasToDisplaySize(canvas) {
//   // look up the size the canvas is being displayed
//   const width = canvas.clientWidth;
//   const height = canvas.clientHeight;
//
//   // If it's resolution does not match change it
//   if (canvas.width !== width || canvas.height !== height) {
//     canvas.width = width;
//     canvas.height = height;
//     return true;
//   }
//
//   return false;
// }

// Coupon is 510px by 300px

let CardEditor = {
  template: '<div class="card-editor-container"><canvas id="card-editor-canvas" class="card-side-canvas" width=1875 height=1275></canvas></div>',
  data: function() {
    return {
      rect: null,
      canvas: null,
      originalCanvasHeight: 1275,
      originalCanvasWidth: 1875,
    }
  },
  beforeDestroy: function () {
    window.removeEventListener('resize', this.handleResize)
  },
  mounted: function() {
    console.log('CardEditor Mounted');
    // this.$nextTick(function () {
    // code that assumes this.$el is in-document
    // });

    // create a wrapper around native canvas element (with id="c")
    this.canvas = new fabric.Canvas('card-editor-canvas', { stateful: true });
    let rect = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.canvas.add(rect);


    this.canvas.on('object:moving', this.handleObjectMoved);

    window.addEventListener('resize', this.handleResize);

    this.handleResize();

    // document.addEventListener('resize', () => { console.log('RESIZING'); });


  },
  methods: {
    handleObjectMoved: function(e) {
      // console.log('handleObjectMoved');
      // console.log('x      : ' + obj.left + ' y      :' + obj.top);
      // console.log('x bound: ' + obj.getBoundingRect().left + ' y bound:' + obj.getBoundingRect().top);

      var obj = e.target;

      // Solution (modified): https://stackoverflow.com/a/24238960/1181104

      if (obj.top < 0) {
        obj.top = 0;
      }
      if (obj.left < 0) {
        obj.left = 0;
      }
      if (obj.top + obj.height > this.originalCanvasHeight) {
        obj.top = this.originalCanvasHeight - obj.height;
      }
      if (obj.left + obj.width > this.originalCanvasWidth) {
        obj.left = this.originalCanvasWidth - obj.width;
      }

    },
    handleResize: function() {
      console.log('handleResize');

      let ratio = (Math.min(this.originalCanvasWidth/3, window.innerWidth)/ 1875) * 0.90;

      this.canvas.setDimensions({ width: this.originalCanvasWidth * ratio, height: this.originalCanvasHeight * ratio });
      this.canvas.setZoom(ratio);
    },
  }
};


export default CardEditor;

