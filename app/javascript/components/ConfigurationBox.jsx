import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import DiscountCodeBox from './DiscountCodeBox';
import DiscountHandler from './DiscountHandler';

const ConfigurationBox = props => (
  <section>
    <div className="mdl-grid">
      <div className="mdl-cell mdl-cell--6-col">
        <h3 className="uppercase">Configure</h3>
        <DiscountHandler
          onCheck={props.onCheck}
          showDiscount={props.includeDiscount}
        />
      </div>
    </div>
  </section>
);

export default ConfigurationBox;
