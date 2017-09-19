import React from 'react';
import ReactDOM from 'react-dom';

const DiscountInputFields = props => (
  <div>
    <div className="mdl-textfield mdl-js-textfield">
      <input className="mdl-textfield__input" type="text" pattern="-?[0-9]*(\.[0-9]+)?" id="percent"/>
      <label className="mdl-textfield__label" htmlFor="percent"><strong>Percent</strong></label>
      <span className="mdl-textfield__error">You must enter a number!</span>
    </div>
    <div className="mdl-textfield mdl-js-textfield">
      <input className="mdl-textfield__input" type="text" pattern="-?[0-9]*(\.[0-9]+)?" id="exp"/>
      <label className="mdl-textfield__label" htmlFor="exp"><strong>Weeks till expiration</strong></label>
      <span className="mdl-textfield__error">You must enter a number!</span>
    </div>
  </div>
);

export default DiscountInputFields;
