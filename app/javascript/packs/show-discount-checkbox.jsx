import React from 'react'
import ReactDOM from 'react-dom'

const ShowDiscountCheckBox = props => {
  if (props.includeDiscount) {
    return (
      <label className="form-check-label">
        { props.includeDiscount }
        <input
          className="form-check-input"
          type="checkbox"
          value=""
          onClick={props.handleClick} />
        { props.text }
      </label>
    )
  } else {
    return null
  }
}

export default ShowDiscountCheckBox
