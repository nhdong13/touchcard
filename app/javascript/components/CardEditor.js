import * as fabric from 'fabric-browseronly'


function resizeCanvasToDisplaySize(canvas) {
  // look up the size the canvas is being displayed
  const width = canvas.clientWidth;
  const height = canvas.clientHeight;

  // If it's resolution does not match change it
  if (canvas.width !== width || canvas.height !== height) {
    canvas.width = width;
    canvas.height = height;
    return true;
  }

  return false;
}

let CardEditor = {
  template: '<canvas id="card-editor" class="card-side-canvas"></canvas>',
  data: function() {
    return {
      rect: null
    }
  },
  mounted: function() {
    console.log('Mounted Card Editor');

    debugger;

    // create a wrapper around native canvas element (with id="c")
    let fabricCanvas= new fabric.Canvas('card-editor');
    let rect = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 80, height: 40, hasControls: false, hasBorders: false });
    fabricCanvas.add(rect);

    this.rect = rect;

    window.rect = rect;
    // rect.hasControls = false;
    // rect.hasBorders = false;

  }
};


export default CardEditor;

