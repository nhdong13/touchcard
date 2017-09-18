import React, { Component } from 'react';
import ReactDOM from 'react-dom';

export default class SelectType extends Component {
  constructor(props) {
    super(props);

    this.state = {
      value: 'FirstPurchaseOrder',
      types: [
        'FirstPurchaseOrder',
        'CustomerWinbackOrder',
        'LifetimePurchaseOrder',
        'AbandonedCheckout'
      ]
    };

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    const value = event.target.value;
    this.setState({ value });
    console.log(this.state.value);
  }

  render() {
    return (
      <div>
        <p>Add selecting type on click here</p>
      </div>
    );
  }
}
