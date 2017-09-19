import React, { Component } from 'react';
import ReactDOM from 'react-dom';

export default class ConfigureCard extends Component {
  constructor(props) {
    super(props);

    this.setNumOfDays = this.setNumOfDays.bind(this);
    this.setFilter = this.setFilter.bind(this);
  }

  setNumOfDays() {
    // todo
  }

  setFilter() {
    // todo
  }

  render() {
    return (
      <div className="row">
        <div className="col-sm-12">
          <CheckBox
            text={'Send to international addresses'}
            handleClick={props.setInternational}
          />
          <div className="form-control">
            <label>
              Send a card number of days
              <input type="text" value={this.state.numOfDays} onChange={this.setNumOfDays} />
            </label>
          </div>
          <div className="form-control">
            <label>
              Customers will only receive a card if they spent more than $
              <input type="text" value={this.state.filter} onChange={this.setFilter} />
            </label>
          </div>
        </div>
      </div>
    );
  }
}
