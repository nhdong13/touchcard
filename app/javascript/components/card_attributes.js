
function safeAccess(obj, key){
  return key.split('.').reduce((nestedObject, key) => {
    if(nestedObject && key in nestedObject) {
      return nestedObject[key];
    }
    return undefined;
  }, obj);
}

export class CardAttributes {

  constructor(card_side_json) {
    this.version = safeAccess(card_side_json, 'version') || 0;
    this.background_url = safeAccess(card_side_json, 'background_url') || null;

    let x = safeAccess(card_side_json, 'discount_x');
    let y = safeAccess(card_side_json, 'discount_y');
    let valid_coords = typeof x == 'number' && typeof y == 'number';

    this.discount_x = valid_coords ? x : null;
    this.discount_y = valid_coords ? y : null;
    // this._last_discount_x // Won't get saved unless rails controller serializes it.
    // objects = []
  }

  // Getters / Setters for computed properties
  set showsDiscount(doesShow) {
    this.discount_x = doesShow ? 40 : null;
    this.discount_y = doesShow ? 60 : null;
  }

  get showsDiscount() {
    return (this.discount_x !== null) && (this.discount_y !== null);
  }


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
