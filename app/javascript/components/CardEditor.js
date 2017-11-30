// import { fabric }from 'fabric-browseronly'
//
// import 'stylesheets/styles/automations'
//
//
// // function resizeCanvasToDisplaySize(canvas) {
// //   // look up the size the canvas is being displayed
// //   const width = canvas.clientWidth;
// //   const height = canvas.clientHeight;
// //
// //   // If it's resolution does not match change it
// //   if (canvas.width !== width || canvas.height !== height) {
// //     canvas.width = width;
// //     canvas.height = height;
// //     return true;
// //   }
// //
// //   return false;
// // }
//
// // Coupon is 510px by 300px
//
// let CardEditor = {
//   // template: '<canvas id="card-editor" class="card-side-canvas" width=625 height=425></canvas>',
//   data: function() {
//     return {
//       rect: null
//     }
//   },
//   mounted: function() {
//     console.log('Mounted Card Editor');
//
//     // create a wrapper around native canvas element (with id="c")
//     let fabricCanvas= new fabric.Canvas('card-editor');
//     let rect = new fabric.Rect({ left: 100, top: 100, fill: 'red', width: 170, height: 100, hasControls: false, hasBorders: false });
//     fabricCanvas.add(rect);
//
//     this.rect = rect;
//
//     // let canvas = this.$el;
//     // // canvas.width = window.innerWidth;
//     // // canvas.height = window.innerHeight;
//     //
//     // canvas.width = 800;
//     // canvas.height = 600;
//     // // canvas.innerWidth = 800;
//     // // canvas.innerHeight = 800;
//
//     window.rect = rect;
//     window.editor = this;
//     // rect.hasControls = false;
//     // rect.hasBorders = false;
//
//
//     // debugger;
//   }
// };
//
//
// export default CardEditor;
//
