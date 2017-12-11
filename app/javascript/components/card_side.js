// Card Side Model
import { fabric } from 'fabric-browseronly'

export class CardSide {

  constructor(attributes, elementId, canvasWidth, canvasHeight) {
    this.attrs = attributes
    this.newImage = null;
    this.fullCanvasWidth = canvasWidth;
    this.fullCanvasHeight = canvasHeight;

    this.canvas = this.createCanvas(elementId, this.attrs.image)

    // Coupon
    this.canvas.coupon = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 510, height: 300, hasControls: false, hasBorders: false });
    this.canvas.add(this.canvas.coupon);
  }

  createCanvas(elementId, backgroundImage) {
    let canvas = new fabric.Canvas(elementId, { stateful: true })
    if (backgroundImage) {
      canvas.setBackgroundImage(backgroundImage, canvas.renderAll.bind(canvas))
    }
    canvas.on('object:moving', this.handleObjectMoved.bind(this))
    return canvas
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
    this.canvas.setDimensions({ width: this.fullCanvasWidth * ratio, height: this.fullCanvasHeight * ratio });
    this.canvas.setZoom(ratio);
  }

  handleObjectMoved (e) {
    let obj = e.target;

    // console.log('handleObjectMoved');
    // console.log('x      : ' + obj.left + ' y      :' + obj.top);
    // console.log('x bound: ' + obj.getBoundingRect().left + ' y bound:' + obj.getBoundingRect().top);

    // Via (modified): https://stackoverflow.com/a/24238960/1181104
    obj.top = (obj.top < 0) ? 0 : obj.top // don't move off top
    obj.left = (obj.left < 0) ? 0 : obj.left // don't move off left
    obj.top = (obj.top + obj.height > this.fullCanvasHeight) ? (this.fullCanvasHeight - obj.height) : obj.top
    obj.left = (obj.left + obj.width > this.fullCanvasWidth) ? (this.fullCanvasWidth - obj.width) : obj.left
  }
}
