import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import SelectTypeForm from '../containers/SelectTypeForm';
import ConfigureCard from '../containers/ConfigureCard';
import SetupCard from '../containers/SetupCard';

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
      return 'Save & Next';
    }
    return 'Save';
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
    <CardWizard name="React" />,
    document.getElementById('react-app'),
  );
});


// if (document.getElementById('react-app')) {
//   document.addEventListener('turbolinks:load', () => {
//     ReactDOM.render(
//       <CardWizard name="React" />
//     );
//   });
// }


// document.addEventListener("DOMContentLoaded", reactOnRailsPageLoaded)
// document.addEventListener('turbolinks:render', reactOnRailsPageLoaded)
// document.addEventListener('turbolinks:before-render', reactOnRailsPageUnloaded)


// document.addEventListener('turbolinks:load', () => {
//   ReactDOM.render(
//     <CardWizard name="React" />,
//     document.getElementById('react-app'),
//   );
// });

// if (document.getElementById('vue-app')) {
//   document.addEventListener('turbolinks:load', () => {
//     Vue({
//       el: '#vue-app',
//       template: '<App/>',
//       components: { App },
//     });
//   });
// }
