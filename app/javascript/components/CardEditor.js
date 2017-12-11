import { fabric } from 'fabric-browseronly'
import template_markup from './CardEditor.html'
import { Api } from '../Api';

// import 'stylesheets/styles/automations'

const FullCanvasWidth = 1875;
const FullCanvasHeight = 1275;


// Card Side Model
class CardSide {

  // ..and an (optional) custom class constructor. If one is
  // not supplied, a default constructor is used instead:
  // constructor() { }

  constructor(attributes, element_id) {
    this.attrs = attributes
    this.newImage = null;

    this.canvas = new CardSideCanvas(element_id, this.attrs.image);
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

}

// TODO: Could maybe extract everything and just put it into CardSide?
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
    // Via (modified): https://stackoverflow.com/a/24238960/1181104
    obj.top = (obj.top < 0) ? 0 : obj.top // don't move off top
    obj.left = (obj.left < 0) ? 0 : obj.left // don't move off left
    obj.top = (obj.top + obj.height > FullCanvasHeight) ? (FullCanvasHeight - obj.height) : obj.top
    obj.left = (obj.left + obj.width > FullCanvasWidth) ? (FullCanvasWidth - obj.width) : obj.left
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
    },
    aws_sign_endpoint: {
      type: String,
      required: true
    }
  },
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
    console.log('CardEditor Mounted')
    // this.$nextTick(function () {
    // code that assumes this.$el is in-document
    // });
    this.api = new Api(this.aws_sign_endpoint)
    this.front = new CardSide(this.front_attributes, 'front-side-canvas');
    this.back = new CardSide(this.back_attributes, 'back-side-canvas');

    this.handleResize();
    window.addEventListener('resize', this.handleResize);
  },
  methods: {
    requestSave: function(ready_callback) {

      // TODO: We should probably move this into CardSide and create an upload process for all files
      let promises = [];
      if (this.front.newImage) {
        promises.push(this.uploadNewBackground(this.front));
      }
      if (this.back.newBackImage) {
        promises.push(this.uploadNewBackground(this.back));
      }
      Promise.all(promises).then((results) => {
        console.log(results);
        ready_callback();
      }).catch(function (err) {
        console.log(err);
        ready_callback();
      });
    },
    uploadNewBackground: function(cardSide) {
      return new Promise((resolve, reject)=> {
        this.api.uploadFileToS3(cardSide.newImage, (error, result) => {
          console.log(error ? error : result);
          if (result) {
            cardSide.attrs.image = result;
            return resolve();
          }
          reject();
        });
      });
    },
    handleResize: function() {
      console.log('handleResize');

      // let ratio = (Math.min(FullCanvasWidth/2, window.innerWidth)/ FullCanvasWidth) * 0.9;
      let ratio = (Math.min(FullCanvasWidth/4, window.innerWidth)/ FullCanvasWidth) * 0.9;
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

