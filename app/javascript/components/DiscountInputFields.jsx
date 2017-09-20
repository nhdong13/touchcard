import React from 'react';
import ReactDOM from 'react-dom';

const DiscountInputFields = props => (
  <div>
    <div>
      <label htmlFor="percent"><strong>Percent</strong></label>
      <input type="number" pattern="-?[0-9]*(\.[0-9]+)?" id="percent" />
    </div>
    <div>
      <label htmlFor="exp"><strong>Weeks till expiration</strong></label>
      <input type="number" pattern="-?[0-9]*(\.[0-9]+)?" id="exp" />
    </div>
  </div>
);

export default DiscountInputFields;
