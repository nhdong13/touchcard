import { fabric } from 'fabric-browseronly'

import template_markup from './CardEditor.html'

// import 'stylesheets/styles/automations'

const FullCanvasWidth = 1875;
const FullCanvasHeight = 1275;


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
  }

  updateBackground(file) {
    this.newImage = file;
    let reader = new FileReader();
    reader.onload = (e) => {
      this.canvas.setBackgroundImage(e.target.result, this.canvas.renderAll.bind(this.canvas));
    };
    reader.readAsDataURL(file);
  }

  resizeCanvas(ratio) {
    this.canvas.setDimensions({ width: FullCanvasWidth * ratio, height: FullCanvasHeight * ratio });
    this.canvas.setZoom(ratio);
  }

  // How about... call serialize from parent component,
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

  props: {
    front_attributes: {
      type: Object,
      required: true
    },
    back_attributes: {
      type: Object,
      required: true
    }
  },

  // watch: {
  //   frontSideImage: function(newVal, oldVal) { // watch it
  //     console.log('Prop changed: ', newVal, ' | was: ', oldVal)
  //   }
  // },
  data: function() {
    return {
      front: null,
      back: null,
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
    this.back = new CardSide(this.back_attributes, 'back-side-canvas');

    window.addEventListener('resize', this.handleResize);
    this.handleResize();

    window.cardEditor = this;

  },
  methods: {

    handleResize: function() {
      console.log('handleResize');

      let ratio = (Math.min(FullCanvasWidth/2, window.innerWidth)/ FullCanvasWidth) * 0.9;
      this.front.resizeCanvas(ratio);
      this.back.resizeCanvas(ratio);

    },
    onUpdateFrontBackground: function(e) {
      this.updateBackground(e, this.front)
    },
    onUpdateBackBackground: function(e) {
      this.updateBackground(e, this.back)
    },
    updateBackground: function(e, cardSide) {
      let files = e.target.files || e.dataTransfer.files;
      if (!files.length)
        return;
      cardSide.updateBackground(files[0]);
    },
  },
  template: template_markup,
};


export default CardEditor;

