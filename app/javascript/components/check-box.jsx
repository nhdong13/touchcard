import React from 'react';
import ReactDOM from 'react-dom';

const CheckBox = props => (
  <label className="mdl-checkbox mdl-js-checkbox mdl-js-ripple-effect" htmlFor="checkbox-1">
    <input type="checkbox" id="checkbox-1" className="mdl-checkbox__input" onClick={props.handleClick} />
    <span className="mdl-checkbox__label">{ props.text }</span>
  </label>
);

export default CheckBox;
