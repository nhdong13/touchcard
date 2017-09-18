import React from 'react';
import ReactDOM from 'react-dom';
import DiscountInputFields from './discount-input-fields';

const DiscountHandler = (props) => {
  if (props.showDiscount) {
    return (
      <div>
        <label className="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" htmlFor="checkbox-1">
          <input type="checkbox" id="checkbox-1" className="mdl-checkbox__input" onClick={props.onCheck} />
          <span className="mdl-checkbox__label">Include Discount</span>
        </label>
        <DiscountInputFields />
      </div>
    );
  }
  return (
    <div>
      <label className="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" htmlFor="checkbox-1">
        <input type="checkbox" id="checkbox-1" className="mdl-checkbox__input" onClick={props.onCheck} />
        <span className="mdl-checkbox__label">Include Discount</span>
      </label>
    </div>
  );
};

export default DiscountHandler;
