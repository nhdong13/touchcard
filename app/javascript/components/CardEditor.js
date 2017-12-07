import { fabric }from 'fabric-browseronly'

// import 'stylesheets/styles/automations'

const FullCanvasWidth = 1875;
const FullCanvasHeight = 1275;

let template_markup = `
    <div class="card-editor-container">
        <canvas id="front-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
        <canvas id="back-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
    </div>
`;

let CardEditor = {
  template: template_markup,
  data: function() {
    return {
      rect: null,
      frontCanvas: null,
      backCanvas: null,
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
    this.frontCanvas = new fabric.Canvas('front-side-canvas', { stateful: true });
    let frontCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.frontCanvas.add(frontCoupon);
    this.frontCanvas.on('object:moving', this.handleObjectMoved);

    this.backCanvas = new fabric.Canvas('back-side-canvas', { stateful: true });
    let backCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.backCanvas.add(backCoupon);
    this.backCanvas.on('object:moving', this.handleObjectMoved);


    window.addEventListener('resize', this.handleResize);
    this.handleResize();

    // document.addEventListener('resize', () => { console.log('RESIZING'); });


  },
  methods: {
    handleObjectMoved: function(e) {
      // console.log('handleObjectMoved');
      // console.log('x      : ' + obj.left + ' y      :' + obj.top);
      // console.log('x bound: ' + obj.getBoundingRect().left + ' y bound:' + obj.getBoundingRect().top);

      let obj = e.target;

      // Solution (modified): https://stackoverflow.com/a/24238960/1181104

      if (obj.top < 0) {
        obj.top = 0;
      }
      if (obj.left < 0) {
        obj.left = 0;
      }
      if (obj.top + obj.height > FullCanvasHeight) {
        obj.top = FullCanvasHeight - obj.height;
      }
      if (obj.left + obj.width > FullCanvasWidth) {
        obj.left = FullCanvasWidth - obj.width;
      }

    },
    handleResize: function() {
      console.log('handleResize');

      let ratio = (Math.min(FullCanvasWidth, window.innerWidth)/ FullCanvasWidth) * 0.45;

      this.frontCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      this.frontCanvas.setZoom(ratio);

      this.backCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      this.backCanvas.setZoom(ratio);
    },
  }
};


export default CardEditor;

