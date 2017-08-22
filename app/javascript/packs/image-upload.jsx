import React, { Component } from 'react'
import ReactDOM from 'react-dom'

export default class ImageUpload extends Component {
  constructor() {
    super()

    this.handleChange = this.handleChange.bind(this)
    this.fileLoaded = this.fileLoaded.bind(this)
  }

  componentDidMount() {
    this.reader = new FileReader()
    this.reader.onload = this.fileLoaded
  }

  fileLoaded(event) {
    this.props.handleFileUpload(event.target.result)
  }

  handleChange(event) {
    if (!event.target.files || !event.target.files[0]) return
    this.reader.readAsDataURL(event.target.files[0])
  }

  render() {
    return (
      <div className="form-group file-upload-stylized">
        <label htmlFor="image-uploader">{this.props.label}</label>
        <input
          className="form-control"
          type="file"
          name="image-uploader"
          id="image-uploader"
          onChange={this.handleChange} />
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
    )
  }
}
