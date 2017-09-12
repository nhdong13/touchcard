import React from 'react';
import ReactDOM from 'react-dom';

const DiscountCodeBox = props => (
  <div className="wrap">
    <div className="percent">{props.percentage}% OFF</div>
    <div className="code">DIS-CNT-COD</div>
    <div className="expiration">EXPIRES {props.expireAt}</div>
  </div>
);

export default DiscountCodeBox;
