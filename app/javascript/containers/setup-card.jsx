import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import CardSide from '../components/card-side';
import ConfigurationBox from '../components/configuration-box';

export default class SetupCard extends Component {
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
      <div className="card-page">
        <ConfigurationBox
          onCheck={this.includeDiscount}
          includeDiscount={this.state.includeDiscount}
        />
        <section className="mdl-grid">
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
        </section>
      </div>
    );
  }
}
