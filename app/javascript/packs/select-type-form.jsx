import React, { Component } from 'react'
import ReactDOM from 'react-dom'

export default class SelectType extends Component {
  constructor(props) {
    super(props)

    this.state = {
      value: "FirstPurchaseOrder",
      types: [
        "FirstPurchaseOrder",
        "CustomerWinbackOrder",
        "LifetimePurchaseOrder",
        "AbandonedCheckout"
      ]
    }

    this.handleChange = this.handleChange.bind(this)
  }

  handleChange(event) {
    const value = event.target.value
    this.setState({ value })
    console.log(this.state.value)
  }

  render() {
    return (
      <div className="row">
        <div className="col-sm-4 col-sm-offset-4">
          <select className="form-control" value={this.state.value} onChange={this.handleChange}>
            <option value={this.state.types[0]}>First Purchase</option>
            <option value={this.state.types[1]}>Customer Winback</option>
            <option value={this.state.types[2]}>Lifetime Purchase</option>
            <option value={this.state.types[3]}>Abandoned Checkout</option>
          </select>
        </div>
      </div>
    )
  }
}
