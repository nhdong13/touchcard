import React from 'react';
import ReactDOM from 'react-dom';

const ShowDiscountCheckBox = (props) => {
  if (props.includeDiscount) {
    return (
      <label className="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect">
        <input type="checkbox" className="mdl-checkbox__input" onClick={props.handleClick}/>
        <span className="mdl-checkbox__label">{ props.text }</span>
      </label>
    );
  }
  return null;
};

export default ShowDiscountCheckBox;
