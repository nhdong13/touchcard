import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import SelectTypeForm from '../containers/SelectTypeForm';
import ConfigureCard from '../containers/ConfigureCard';
import SetupCard from '../containers/SetupCard';
import PropTypes from 'prop-types';


export default class CardWizard extends Component {
  constructor(props) {
    super(props);

    this.state = {
      step: 1
    };

    this.switchStep = this.switchStep.bind(this);
  }

  buttonText() {
    if (this.state.step === 1) {
      return 'Next';
    }
    if (this.state.step === 2) {
      return 'Next';
    }
    return 'Finish';
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
          <div className="top-m-20">
            <div className="mdl-grid">
              <div className="mdl-layout-spacer" />
              <button onClick={this.switchStep} className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored">
                {this.buttonText()}
              </button>
              <div className="mdl-layout-spacer" />
            </div>
            <SelectTypeForm />
          </div>
        );
      case 2:
        return (
          <div className="top-m-20">
            <div className="mdl-grid">
              <div className="mdl-layout-spacer" />
              <button onClick={this.switchStep} className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored">
                {this.buttonText()}
              </button>
              <div className="mdl-layout-spacer" />
            </div>
            <SetupCard />
          </div>
        );
      case 3:
        return (
          <div className="top-m-20">
            <div className="mdl-grid">
              <div className="mdl-layout-spacer" />
              <form onSubmit={this.handleSubmit} action="/automations" method="post">
                <input type="hidden" name="cardType" value="PostSaleOrder" />
                <input type="hidden" name="authenticity_token" value={this.props.csrfToken} />
                <input type="submit" value="Submit" className="mdl-button mdl-js-button mdl-button--raised mdl-button--colored"/>
              </form>
              <div className="mdl-layout-spacer" />
            </div>
            <ConfigureCard />
          </div>
        );
      default:
        return null;
    }
  }
}


CardWizard.propTypes = {
  csrfToken: PropTypes.string.isRequired
};


console.log('Adding Event Listener - CardWizard');
document.addEventListener('DOMContentLoaded', () => {
  // console.log('DOMContentLoaded - CardWizard');
  const csrfToken = document.querySelectorAll('meta[name="csrf-token"]')[0].getAttribute('content');
  // console.log('csrfToken:' + csrfToken);
  ReactDOM.render(
    <CardWizard name="React" csrfToken={csrfToken} />,
    document.getElementById('react-app'),
  );
});


// if (document.getElementById('react-app')) {
//   console.log('document has react-app - CardWizard');
//   document.addEventListener('turbolinks:load', () => {
//     console.log('turbolinks:load - CardWizard');
//     ReactDOM.render(
//       <CardWizard name="React" />,
//       document.getElementById('react-app'),
//     );
//   });
// }
//
// document.addEventListener("DOMContentLoaded", reactOnRailsPageLoaded)
// document.addEventListener('turbolinks:render', reactOnRailsPageLoaded)
// document.addEventListener('turbolinks:before-render', reactOnRailsPageUnloaded)

