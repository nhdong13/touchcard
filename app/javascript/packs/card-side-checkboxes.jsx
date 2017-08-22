import React from 'react'
import ReactDOM from 'react-dom'

const CardSideCheckboxes = props => {
  return (
    <div>
      <label className="form-check-label">
        <input className="form-check-input" type="checkbox" value="" />
        Show discount code on this side
      </label>
      <label className="form-check-label">
        <input
          className="form-check-input"
          type="checkbox"
          value=""
          onClick={props.toggleShowSafeArea} />
        Show safe-area - This is area where text can be
      </label>
      <label className="form-check-label">
        <input
          className="form-check-input"
          type="checkbox"
          value=""
          onClick={props.toggleShowBleed} />
        Show bleed - Anything outside of this area will be trimmed
      </label>
    </div>
  )
}

export default CardSideCheckboxes
