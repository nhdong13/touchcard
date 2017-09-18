import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import DiscountCodeBox from './discount-code-box';
import DiscountHandler from './discount-handler';

const ConfigurationBox = props => (
  <section>
    <div className="mdl-grid">
      <div className="mdl-cell mdl-cell--6-col">
        <h3>Configure</h3>
        <DiscountHandler
          onCheck={props.onCheck}
          showDiscount={props.includeDiscount}
        />
      </div>
      <div className="mdl-cell mdl-cell--6-col pull-right">
        <button className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored">
          Save
        </button>
        <button className="mdl-button mdl-js-button mdl-button--raised">Cancel</button>
      </div>
    </div>
  </section>
);

export default ConfigurationBox;
