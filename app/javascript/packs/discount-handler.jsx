import React from 'react';
import ReactDOM from 'react-dom';
import DiscountInputFields from './discount-input-fields';

const DiscountHandler = (props) => {
  if (props.showDiscount) {
    return (
      <div>
        <div className="form-check">
          <label className="form-check-label">
            <input className="form-check-input" type="checkbox" value="" onClick={props.onCheck} />
            Include Discount
          </label>
        </div>
        <DiscountInputFields />
      </div>
    );
  }
  return (
    <div className="form-check">
      <label className="form-check-label">
        <input className="form-check-input" type="checkbox" value="" onClick={props.onCheck} />
          Include Discount
      </label>
    </div>
  );
};

export default DiscountHandler;
