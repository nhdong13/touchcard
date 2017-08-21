import React from 'react'
import ReactDOM from 'react-dom'
import DiscountCodeBox from './discount-code-box'

const CardSide = props => {
  return (
    <div className="col-sm-6">
      <h2>{props.title}</h2>
      <label className="form-check-label">
        <input className="form-check-input" type="checkbox" value="" />
        Show discount code on this side
      </label>
      <label className="form-check-label">
        <input className="form-check-input" type="checkbox" value="" />
        Show safe-area - This is area where text can be
      </label>
      <label className="form-check-label">
        <input className="form-check-input" type="checkbox" value="" />
        Show bleed - Anything outside of this area will be trimmed
      </label>
      <div className="card-side">
        <div className="layers">
          <div className="discount layer">
            <div className="card-side {/*if isEditable 'is-editable' */}">
              <DiscountCodeBox percentage={10} expireAt={10-10-10}/>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default CardSide
