import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import CardSide from './card-side'
import ConfigurationBox from './configuration-box'

const AutomationHandler = props => {
  return (
    <div className="row">
      <ConfigurationBox />
      <CardSide title={"Image Side"}/>
      <CardSide title={"Address Side"}/>
    </div>
  )
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <AutomationHandler name="React" />,
    document.getElementById("react-app"),
  )
})
