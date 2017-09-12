import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import DiscountCodeBox from './discount-code-box';
import DiscountHandler from './discount-handler';

const ConfigurationBox = props => (
  <section>
    <div className="row">
      <div className="col-sm-6">
        <h2>Configure</h2>
        <DiscountHandler
          onCheck={props.onCheck}
          showDiscount={props.includeDiscount}
        />
      </div>
      <div className="col-sm-6 pull-right">
        <button className="btn btn-primary btn-lg pull-right save">Save</button>
        <button className="btn btn-default btn-lg pull-right cancel">Cancel</button>
      </div>
    </div>
  </section>
);

export default ConfigurationBox;
