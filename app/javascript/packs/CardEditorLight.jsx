import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';

// import SelectTypeForm from '../containers/select-type-form';
// import ConfigureCard from '../containers/configure-card';
// import SetupCard from '../containers/setup-card';

export default class CardEditorLight extends Component {
  // constructor(props) {
  //   super(props);
  // }

  render() {
    return (
      <form onSubmit={this.handleSubmit} action="/automations" method="post">
        <label>
          Name: {this.props.csrfToken}
          <input type="text" value="blah" onChange="" onSubmit="" />
          <input name="authenticity_token" type="hidden" value={this.props.csrfToken} />
        </label>
        <input type="submit" value="Submit" />
      </form>

    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const csrfToken = document.querySelectorAll('meta[name="csrf-token"]')[0].getAttribute('content');
  console.log(`csrfToken:${csrfToken}`);
  ReactDOM.render(
    <CardEditorLight name="CardEditorLight" csrfToken={csrfToken} />,
    document.getElementById('react-app'),
  );
});

CardEditorLight.propTypes = {
  csrfToken: PropTypes.string.isRequired
};

// document.addEventListener('DOMContentLoaded', () => {
//   const node = document.getElementById('appointments_data')
//   const data = JSON.parse(node.getAttribute('data'))
//   ReactDOM.render(
//     <Appointments appointments={data} />,
//     document.body.appendChild(document.createElement('div')),
//   )
// })
