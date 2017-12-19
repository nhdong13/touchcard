// @flow
import { fabric } from 'fabric-browseronly'

class Discount extends fabric.Group {
  constructor() {

    const DiscountWidth = 510;
    const DiscountHeight = 300;

    let backgroundRect = new fabric.Rect({
      opacity: 0,
      width: DiscountWidth,
      height: DiscountHeight,
    });

    let discountAmount = new fabric.Text('20% OFF', {
      fontSize: 94,
      fontFamily: 'Montserrat',
      fontWeight: 800,
      textAlign: 'center',
      originX: 'center',
      originY: 'top',
      left: DiscountWidth/2,
      top: 24,
    });

    let code = new fabric.Text('ABC-DEF-GHI', {
      fontSize: 52,
      fontFamily: 'Montserrat',
      originX: 'center',
      originY: 'top',
      left: DiscountWidth/2,
      top: 136 //discountAmount.height + discountAmount.top
    });

    let expiration = new fabric.Text('EXPIRES 12/12/2017', {
      fontSize: 28,
      fontFamily: 'Montserrat',
      originX: 'center',
      originY: 'bottom',
      left: DiscountWidth/2,
      top: DiscountHeight - 36,
    });

    super(
      [backgroundRect, discountAmount, code, expiration],
      {
        hasControls: false,
        hasBorders: false,
        selectionBackgroundColor: 'rgba(235,235,235, 0.5)',
      });
  }
}


export class CardSide {

  constructor(attributes, elementId, canvasWidth, canvasHeight) {
    this.attrs = attributes
    this.newImage = null;
    this.fullCanvasWidth = canvasWidth;
    this.fullCanvasHeight = canvasHeight;
    this._canvas = this._createCanvas(elementId, this.attrs.image)
  }

  // Export:
  // this._canvas.toSVG({suppressPreamble: true})

  addDiscount() {
    if (!this._discount) {
      this._discount = new Discount();
      this._canvas.add(this._discount);
      this._discount.viewportCenter().setCoords();
    }
  }

  removeDiscount() {
    this._canvas.remove(this._discount);
    this._discount = null;
  }

  updateBackground(file) {
    this.newImage = file;
    let reader = new FileReader();
    reader.onload = (e) => {
      this._canvas.setBackgroundImage(e.target.result, this._canvas.renderAll.bind(this._canvas));
    };
    reader.readAsDataURL(file);
  }

  resizeCanvas(ratio) {
    let newWidth = this.fullCanvasWidth * ratio;
    let newHeight = this.fullCanvasHeight * ratio;
    this._canvas.setDimensions({ width: newWidth, height: newHeight});
    this._canvas.setZoom(ratio);
  }

  handleObjectMoved (e) {
    let obj = e.target;

    // console.log('handleObjectMoved');
    // console.log('x      : ' + obj.left + ' y      :' + obj.top);
    // console.log('x bound: ' + obj.getBoundingRect().left + ' y bound:' + obj.getBoundingRect().top);
    // console.log(obj.constructor.name)
    // console.log(Discount.name)

    const SafeAreaMargin = 60;  // Actually 56.25, but extra 3 pixels can't hurt

    if (obj.constructor.name === Discount.name) {
      // Via (modified): https://stackoverflow.com/a/24238960/1181104
      obj.top = (obj.top < SafeAreaMargin) ? SafeAreaMargin : obj.top // don't move off top
      obj.left = (obj.left < SafeAreaMargin) ? SafeAreaMargin : obj.left // don't move off left
      obj.top = (obj.top + obj.height > (this.fullCanvasHeight - SafeAreaMargin)) ? ((this.fullCanvasHeight - SafeAreaMargin) - obj.height) : obj.top
      obj.left = (obj.left + obj.width > (this.fullCanvasWidth - SafeAreaMargin)) ? ((this.fullCanvasWidth - SafeAreaMargin) - obj.width) : obj.left
    }
  }

  handleMouseOver (e) {
    if (e && e.target) {
      this._canvas.setActiveObject(e.target).renderAll();
    }
  }

  handleMouseOut (e) {
    if (e && e.target) {
      this._canvas.deactivateAll().renderAll();
    }
  }

  // --- Pseudo Private Methods

  _createCanvas(elementId, backgroundImage) {
    let canvas = new fabric.Canvas(elementId, { stateful: true });
    if (backgroundImage) {
      canvas.setBackgroundImage(backgroundImage, canvas.renderAll.bind(canvas));
    }
    canvas.on('object:moving', this.handleObjectMoved.bind(this));
    canvas.on('mouse:over', this.handleMouseOver.bind(this));
    canvas.on('mouse:out', this.handleMouseOut.bind(this));
    return canvas;
  }

}
