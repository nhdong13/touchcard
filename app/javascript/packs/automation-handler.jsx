import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import CardSide from './card-side';
import ConfigurationBox from './configuration-box';

class AutomationHandler extends Component {
  constructor() {
    super();

    this.state = {
      includeDiscount: false
    };

    this.includeDiscount = this.includeDiscount.bind(this);
  }

  includeDiscount() {
    this.setState(prevState => ({
      includeDiscount: !prevState.includeDiscount
    }));
  }

  render() {
    return (
      <div className="card-page container-fluid">
        <ConfigurationBox
          onCheck={this.includeDiscount}
          includeDiscount={this.state.includeDiscount}
        />
        <CardSide
          title={'Image Side'}
          isBack={false}
          includeDiscount={this.state.includeDiscount}
        />
        <CardSide
          title={'Address Side'}
          isBack
          includeDiscount={this.state.includeDiscount}
        />
      </div>
    );
  }
}
