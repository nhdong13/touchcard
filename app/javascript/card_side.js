
function safeAccess(obj, key){
  return key.split('.').reduce((nestedObject, key) => {
    if(nestedObject && key in nestedObject) {
      return nestedObject[key];
    }
    return undefined;
  }, obj);
}


export class CardSide {

  constructor(card_side_json) {
    this.version = safeAccess(card_side_json, 'version') || 0;
    this.background_url = safeAccess(card_side_json, 'background_url') || null;
    this.discount_x = safeAccess(card_side_json, 'discount_x') || null;
    this.discount_y = safeAccess(card_side_json, 'discount_y') || null;
    // objects = []
  }


  // set computed_property (arg) {
  //   console.log(`set computed_property: ${arg}`);
  // }
  // get computed_property () {
  //   console.log('get computed_property');
  //   return "";
  // }


  // --- Pseudo Private Methods

  // _defaultAttributes() {
  //   this.version = 0;
  //   this.background_url = null;
  //   this.discount_x = null;
  //   this.discount_y = null;
  //   // 'objects' : []
  // }


  // _hasValidAttributes(attrs) {
  //   if (attrs === null) {
  //     return false;
  //   }
  //   let valid = true;
  //   let data = this.defaultAttributes();
  //   valid &= 'version' in attrs && attrs.version === data.version;
  //   for (var key in data) {
  //     // check if the property/key is defined in the object itself, not in parent
  //     if (data.hasOwnProperty(key)) {
  //       valid &= key in attrs;
  //     }
  //   }
  //   return valid;
  // }

}
