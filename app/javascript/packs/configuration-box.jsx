import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import DiscountCodeBox from './discount-code-box'

export default class ConfigurationBox extends Component {
  constructor(props) {
    super(props)

    this.state = {
      includeDiscount: false
    }

    this.includeDiscount = this.includeDiscount.bind(this)
  }

  includeDiscount() {
    this.setState(prevState => ({
      includeDiscount: !prevState.includeDiscount
    }))
  }

  render() {
    return (
      <div className="col-sm-12">
        <div className="row">
          <div className="col-sm-6">
            <h2>Configure</h2>
            <div className="form-check">
              <label className="form-check-label">
                <input className="form-check-input" type="checkbox" value="" onClick={this.includeDiscount} />
                Include Discount
              </label>
            </div>
            <div class="form-group">
              <label htmlFor="discount-pct">Coupon Percent</label>
              <input class="form-control" id="discount-pct" size="2" />
            </div>
            <div class="form-group">
              <label htmlFor="discount-exp">Weeks till Expiration</label>
              <input class="form-control" id="discount-exp" size="2" />
            </div>
          </div>
          <div className="col-sm-6 pull-right">
            <button className="btn btn-default btn-lg pull-right cancel">Cancel</button>
            <button className="btn btn-primary btn-lg pull-right save">Save</button>
          </div>
        </div>
      </div>
    )
  }
}
