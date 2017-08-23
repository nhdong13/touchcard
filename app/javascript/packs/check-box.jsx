import React from 'react'
import ReactDOM from 'react-dom'

const CheckBox = props => {
  return (
    <label className="form-check-label">
      <input
        className="form-check-input"
        type="checkbox"
        value=""
        onClick={props.handleClick} />
      { props.text }
    </label>
  )
}

export default CheckBox
