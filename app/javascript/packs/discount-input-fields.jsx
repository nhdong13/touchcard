import React from 'react';
import ReactDOM from 'react-dom';

const DiscountInputFields = props => (
  <div>
    <div className="form-group">
      <label htmlFor="discount-pct">Coupon Percent</label>
      <input id="discount-pct" size="2" />
    </div>
    <div className="form-group">
      <label htmlFor="discount-exp">Weeks till Expiration</label>
      <input id="discount-exp" size="2" />
    </div>
  </div>
);

export default DiscountInputFields;
