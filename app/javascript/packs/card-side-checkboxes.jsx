import React from 'react';
import ReactDOM from 'react-dom';
import CheckBox from './check-box.jsx';
import ShowDiscountCheckBox from './show-discount-checkbox';

const CardSideCheckboxes = props => (
  <div>
    <ShowDiscountCheckBox
      includeDiscount={props.includeDiscount}
      text={'Show discount code on this side'}
    />
    <CheckBox
      text={'Show safe-area - This is area where text can be'}
      handleClick={props.toggleShowSafeArea}
    />
    <CheckBox
      text={'Show bleed - Anything outside of this area will be trimmed'}
      handleClick={props.toggleShowBleed}
    />
  </div>
);

export default CardSideCheckboxes;
