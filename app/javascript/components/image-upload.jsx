import React, { Component } from 'react';
import ReactDOM from 'react-dom';

export default class ImageUpload extends Component {
  constructor() {
    super();

    this.state = {
      error: false
    };

    this.handleChange = this.handleChange.bind(this);
    this.fileLoaded = this.fileLoaded.bind(this);
  }

  componentDidMount() {
    this.reader = new FileReader();
    this.reader.onload = this.fileLoaded;
  }

  fileLoaded(event) {
    let img = new Image();
    const _this = this;
    img.onload = function () {
      if (_this.validImage(this)) {
        _this.props.handleFileUpload(event.target.result);
      } else {
        img = null;
        _this.setState(prevState => ({
          error: !prevState.error
        }));
      }
    };
    img.src = event.target.result;
  }

  validImage(img) {
    return img.height === 1875 && img.height === 1275;
  }

  handleChange(event) {
    if (!event.target.files || !event.target.files[0]) return;
    this.reader.readAsDataURL(event.target.files[0]);
  }

  renderError() {
    return this.state.error ?
      <div className="alert alert-danger">Image must be 1875px by 1275px</div> :
      null;
  }

  render() {
    return (
      <div>
      <div className="file-upload-stylized mdl-textfield mdl-js-textfield full-width">
        <input
          className="mdl-textfield__input"
          onChange={this.handleChange}
          type="file"
          id="image-uploader" />
        <div>
          <small className="help-block">
            Image must be 1875px by 1275px including a 75px bleed -
            <a href="/images/{this.props.isBack ? 'address' : 'image'}}-side-guide.jpg" target="_blank">
              template
            </a>,
            <a href="/images/{this.props.isBack ? 'address' : 'image'}-side-example.jpg" target="_blank">
              example
            </a>
          </small>
        </div>
      </div>
        { this.renderError() }
      </div>
    );
  }
}
