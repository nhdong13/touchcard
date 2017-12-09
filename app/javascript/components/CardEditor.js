import { fabric } from 'fabric-browseronly'

// import 'stylesheets/styles/automations'

const FullCanvasWidth = 1875;
const FullCanvasHeight = 1275;

//------------------------------------------------------------------------

let template_markup = `
    <div class="card-editor-container">
        <!--<hr />-->
        <h2>Front</h2>
        Select an image: <input type="file" accept="image/png,image/jpeg"  v-on:change="onUpdateFrontBackground">
        <br>
        <!--<img class="card-side-image" v-bind:src="newFrontImageData || this.front.image">-->

        <canvas id="front-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
        <p></p>
        <canvas id="back-side-canvas" class="card-side-canvas" width=${FullCanvasWidth} height=${FullCanvasHeight}></canvas>
    </div>
`;

//------------------------------------------------------------------------

// Card Side Model
class CardSide {

  // ..and an (optional) custom class constructor. If one is
  // not supplied, a default constructor is used instead:
  // constructor() { }

  constructor(attributes, element_id) {
    this.image = attributes.image;
    this.discount_x = attributes.discount_x;
    this.discount_y = attributes.discount_y;
    this.newImage = null;

    this.canvas = new CardSideCanvas(element_id, this.image);

    // canvas
    // newImage
    // newImageData
    //
  }

  updateBackground(file) {
    this.newImage = file;
    this.createImage(this.newImage, (fileData) => {
      this.canvas.setBackgroundImage(fileData, this.canvas.renderAll.bind(this.canvas));
    });
  }

  createImage(file, onLoad) {
    let reader = new FileReader();
    reader.onload = (e) => {
      onLoad(e.target.result);
    };
    reader.readAsDataURL(file);
  }


  resizeCanvas(ratio) {
    this.canvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
    this.canvas.setZoom(ratio);
  }


  // How aboutd... call serialize from parent component,
  // then during serialize upload the files, when done
  // return the full version?
  //
  // This way would be 'future proof' if we need to wait on
  // other uploads for the serialize to be ready
  //
  // serialize(){
  //  // TODO: if this.newImage make sure it's uploaded
  // }
}

class CardSideCanvas extends fabric.Canvas {
  constructor(element_id, background_image) {

    super(element_id, { stateful: true });
    this.frontCanvas = new fabric.Canvas('front-side-canvas', { stateful: true });
    this.coupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.add(this.coupon);
    this.on('object:moving', this.handleObjectMoved);

    if (background_image) {
      this.setBackgroundImage(background_image, this.renderAll.bind(this));
    }

  }

  handleObjectMoved (e) {
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
  }

}

//------------------------------------------------------------------------

let CardEditor = {
  props: ['front_attributes', 'back'],
  // watch: {
  //   frontSideImage: function(newVal, oldVal) { // watch it
  //     console.log('Prop changed: ', newVal, ' | was: ', oldVal)
  //   }
  // },
  data: function() {
    return {
      front: null,
      // back: null,
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

    this.front = new CardSide(this.front_attributes, 'front-side-canvas');



    // this.frontCanvas = new fabric.Canvas('front-side-canvas', { stateful: true });
    // let frontCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    // this.frontCanvas.add(frontCoupon);
    // this.frontCanvas.on('object:moving', this.handleObjectMoved);

    this.backCanvas = new fabric.Canvas('back-side-canvas', { stateful: true });
    let backCoupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.backCanvas.add(backCoupon);
    this.backCanvas.on('object:moving', this.handleObjectMoved);


    console.log('this.front.image: ' + this.front.image);
    // this.frontCanvas.setBackgroundImage(this.front.image, this.frontCanvas.renderAll.bind(this.frontCanvas));
    // this.frontCanvas.setBackgroundImage(this.front.image, this.frontCanvas.renderAll.bind(this.frontCanvas));

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

      this.front.resizeCanvas(ratio);

      // this.frontCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      // this.frontCanvas.setZoom(ratio);

      this.backCanvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
      this.backCanvas.setZoom(ratio);
    },
    onUpdateFrontBackground: function(e, cardSide) {
      this.updateBackground(e, this.front)
    },
    onUpdateBackBackground: function(e, cardSide) {
      this.updateBackground(e, this.back)
    },
    updateBackground: function(e, cardSide) {
      let files = e.target.files || e.dataTransfer.files;
      if (!files.length)
        return;
      cardSide.updateBackground(files[0]);
    },
    // onNewBackImage: function(e) {
    //   let files = e.target.files || e.dataTransfer.files;
    //   if (!files.length)
    //     return;
    //   this.newBackImage = files[0];
    //   this.createImage(this.newBackImage, (fileData) => {
    //     this.backCanvas.setBackgroundImage(fileData, this.backCanvas.renderAll.bind(this.backCanvas));
    //   });
    // },
    // onNewFrontImage: function(e) {
    //   let files = e.target.files || e.dataTransfer.files;
    //   if (!files.length)
    //     return;
    //   this.newFrontImage = files[0];
    //
    //   this.createImage(this.newFrontImage, (fileData) => {
    //     this.frontCanvas.setBackgroundImage(fileData, this.frontCanvas.renderAll.bind(this.frontCanvas));
    //   });
    // },
    // createImage: function(file, onLoad) {
    //   let reader = new FileReader();
    //   reader.onload = (e) => {
    //     onLoad(e.target.result);
    //   };
    //   reader.readAsDataURL(file);
    // }
  },
  template: template_markup,
};


export default CardEditor;

