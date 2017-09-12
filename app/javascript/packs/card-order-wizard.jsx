import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import SelectTypeForm from '../containers/select-type-form';
import ConfigureCard from '../containers/configure-card';
import SetupCard from '../containers/setup-card';

export default class CardOrderWizard extends Component {
  constructor(props) {
    super(props);

    this.state = {
      step: 1
    };

    this.switchStep = this.switchStep.bind(this);
  }

  buttonText() {
    switch (this.state.step) {
      case 1:
        return 'Next';
      case 2:
        return 'Save & Next';
      case 3:
        return 'Save';
    }
  }

  switchStep() {
    this.setState(prevState => ({
      step: prevState.step + 1
    }));
  }

  render() {
    switch (this.state.step) {
      case 1:
        return (
          <div>
            <SelectTypeForm />
            <button onClick={this.switchStep} className="btn btn-primary">
              {this.buttonText()}
            </button>
          </div>
        );
      case 2:
        return (
          <div>
            <SetupCard />
            <button onClick={this.switchStep} className="btn btn-primary">
              {this.buttonText()}
            </button>
          </div>
        );
      case 3:
        return (
          <div>
            <ConfigureCard />
            <button onClick={this.switchStep} className="btn btn-primary">
              {this.buttonText()}
            </button>
          </div>
        );
      default:
        return null;
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <CardOrderWizard name="React" />,
    document.getElementById('react-app'),
  );
});
