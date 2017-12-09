import { fabric }from 'fabric-browseronly'

// import 'stylesheets/styles/automations'

const FullCanvasWidth = 1875;
const FullCanvasHeight = 1275;

//------------------------------------------------------------------------

let template_markup = `
    <div class="card-editor-container">
        <!--<hr />-->
        <h2>Front</h2>
        Select an image: <input type="file" accept="image/png,image/jpeg"  v-on:change="onNewFrontImage">
        <br>
        <!--<img class="card-side-image" v-bind:src="newFrontImageData || this.front.image">-->

        <canvas id="front-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
        <p></p>
        <canvas id="back-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
    </div>
`;



//------------------------------------------------------------------------

let CardEditor = {
  props: ['front', 'back'],
  // watch: {
  //   frontSideImage: function(newVal, oldVal) { // watch it
  //     console.log('Prop changed: ', newVal, ' | was: ', oldVal)
  //   }
  // },
  data: function() {
    return {
      rect: null,
      frontCanvas: null,
      backCanvas: null,
      newFrontImage: null,
      newFrontImageData: null,
      newBackImage: null,
      newBackImageData: null
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

    this.frontCanvas = new fabric.Canvas('front-side-canvas', { stateful: true });
    let frontCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.frontCanvas.add(frontCoupon);
    this.frontCanvas.on('object:moving', this.handleObjectMoved);

    this.backCanvas = new fabric.Canvas('back-side-canvas', { stateful: true });
    let backCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.backCanvas.add(backCoupon);
    this.backCanvas.on('object:moving', this.handleObjectMoved);


    console.log('this.front.image: ' + this.front.image);
    // this.frontCanvas.setBackgroundImage(this.front.image, this.frontCanvas.renderAll.bind(this.frontCanvas));
    this.frontCanvas.setBackgroundImage(this.front.image, this.frontCanvas.renderAll.bind(this.frontCanvas));

    window.addEventListener('resize', this.handleResize);
    this.handleResize();

    window.frontCanvas = this.frontCanvas;
    // document.addEventListener('resize', () => { console.log('RESIZING'); });

    console.log('this.front: ' + this.front);
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

      let ratio = (Math.min(FullCanvasWidth/2, window.innerWidth)/ FullCanvasWidth) * 0.9;

      this.frontCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      this.frontCanvas.setZoom(ratio);

      this.backCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      this.backCanvas.setZoom(ratio);
    },
    onNewBackImage: function(e) {
      let files = e.target.files || e.dataTransfer.files;
      if (!files.length)
        return;
      this.newBackImage = files[0];
      this.createImage(this.newBackImage, (fileData) => {
        this.backCanvas.setBackgroundImage(fileData, this.backCanvas.renderAll.bind(this.backCanvas));
      });
    },
    onNewFrontImage: function(e) {
      let files = e.target.files || e.dataTransfer.files;
      if (!files.length)
        return;
      this.newFrontImage = files[0];

      this.createImage(this.newFrontImage, (fileData) => {
        this.frontCanvas.setBackgroundImage(fileData, this.frontCanvas.renderAll.bind(this.frontCanvas));
      });
    },
    createImage: function(file, onLoad) {
      let reader = new FileReader();
      reader.onload = (e) => {
        onLoad(e.target.result);
      };
      reader.readAsDataURL(file);
    }
  },
  template: template_markup,
};


export default CardEditor;

