import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import CheckBox from '../components/check-box'

export default class ConfigureCard extends Component {
  constructor(props) {
    super(props);

    this.state = {
      numOfDays: "",
      filter: ""
    };

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
      <section>
        <div>
          <CheckBox
            text={'Send to international addresses'}
            handleClick={this.props.setInternational}
          />
          <div>
            <label>
              Send a card number of days
              <input type="text" value={this.state.numOfDays} onChange={this.state.setNumOfDays} />
            </label>
          </div>
          <div>
            <label>
              Customers will only receive a card if they spent more than $
              <input type="text" value={this.state.filter} onChange={this.setFilter} />
            </label>
          </div>
        </div>
      </section>
    );
  }
}
