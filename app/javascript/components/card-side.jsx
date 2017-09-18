import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import DiscountCodeBox from './discount-code-box';
import CardSideCheckboxes from './card-side-checkboxes';
import ImageUpload from './image-upload';
import Draggable from 'react-draggable';

export default class CardSide extends Component {
  constructor(props) {
    super(props);

    this.state = {
      showBleed: false,
      showSafeArea: false,
      showDiscount: false,
      imageSrc: null
    };

    this.toggleShowBleed = this.toggleShowBleed.bind(this);
    this.toggleShowSafeArea = this.toggleShowSafeArea.bind(this);
    this.setImage = this.setImage.bind(this);
  }

  toggleShowBleed() {
    this.setState(prevState => ({
      showBleed: !prevState.showBleed
    }));
  }

  toggleShowSafeArea() {
    this.setState(prevState => ({
      showSafeArea: !prevState.showSafeArea
    }));
  }

  setImage(src) {
    this.setState({ imageSrc: src });
  }

  renderImage() {
    if (this.state.imageSrc) {
      return (
        <div className="layer">
          <img className="image" src={imageSrc} />
        </div>
      );
    }
    null;
  }

  render() {
    return (
      <section className="mdl-cell mdl-cell--6-col">
        <h3 className="uppercase">{this.props.title}</h3>
        <ImageUpload label={'Upload Image'} handleFileUpload={this.setImage} />
        <CardSideCheckboxes
          includeDiscount={this.props.includeDiscount}
          toggleShowBleed={this.toggleShowBleed}
          toggleShowSafeArea={this.toggleShowSafeArea}
        />
        <div className="layers">
          <div className={`layer ${this.state.showBleed ? 'bleed' : ''}`} />
          <div className={`layer ${this.state.showSafeArea ? 'safe-area' : ''}`} />
          <div className="card-side">
            <div className="layers">
              <div className="postage layer">
                <img src="/images/postage.png" />
              </div>
              <Draggable>
                <div className="discount layer">
                  <DiscountCodeBox percentage={10} expireAt={10 - 10 - 10} />
                </div>
              </Draggable>
              <div className="layer">
                <img className="image" src={this.state.imageSrc} />
              </div>
            </div>
          </div>
        </div>
      </section>
    );
  }
}
