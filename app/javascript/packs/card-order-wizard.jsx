import React, { Component } from 'react'
import ReactDOM from 'react-dom'
import SelectTypeForm from './select-type-form'
import ConfigureCard from './configure-card'
import SetupCard from './setup-card'

export default class CardOrderWizard extends Component {
  constructor(props) {
    super(props)

    this.state = {
      step: 1
    }
  }

  buttonText() {
    switch (this.state.step) {
      case 1:
        return "Next"
      case 2:
        return "Save & Next"
      case 3:
        return "Save"
    }
  }

  render() {
    switch (this.state.step) {
      case 1:
        return (
          <div>
            <SelectTypeForm />
            <button className="btn btn-primary">{this.buttonText()}</button>
          </div>
        )
      case 2:
        return (
          <div>
            <SetupCard />
            <button className="btn btn-primary">{this.buttonText()}</button>
          </div>
        )
      case 3:
        return (
          <div>
            <ConfigureCard />
            <button className="btn btn-primary">{this.buttonText()}</button>
          </div>
        )
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <CardOrderWizard name="React" />,
    document.getElementById("react-app"),
  )
})
