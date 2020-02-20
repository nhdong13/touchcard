
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
    let coords_valid = typeof x == 'number' && typeof y == 'number';

    this.discount_x = coords_valid ? x : null;
    this.discount_y = coords_valid ? y : null;
    // this._last_discount_x // Won't get saved unless rails controller serializes it.
    // objects = []
  }

  // Getters / Setters for computed properties
  set showsDiscount(doesShow) {
    if (doesShow) {
      this.discount_x = (typeof this.discount_x == 'number') ? this.discount_x : 40;
      this.discount_y = (typeof this.discount_y == 'number') ? this.discount_y : 60;
    } else {
      this.discount_x = null;
      this.discount_y = null;
    }
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
