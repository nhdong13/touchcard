import axios from 'axios'

export class Api {

  constructor(awsSignEndpoint) {
    this.awsSignEndpoint = awsSignEndpoint;
  }

  uploadFileToS3 (file, callback) {
    if (typeof this.awsSignEndpoint == 'undefined') {
      throw 'Missing Upload URL';
    }
    // Get S3 Upload URL from Touchcard Server
    axios.get(this.awsSignEndpoint, {
      params: {
        name: file.name,
        type: file.type
      }
    })
      .then(function (result) {
        var signedUrl = result.data.signedUrl;

        var options = {
          headers: {
            'Content-Type': file.type
          }
        };
        // Upload File to S3
        axios.put(signedUrl, file, options)
          .then(function (result) {
            var imageUrl = result.request.responseURL && result.request.responseURL.split('?')[0];
            if (typeof callback === 'function') {
              callback(null, imageUrl);
            }
          })
          .catch(function (err) {
            console.log(err);
            if (typeof callback === 'function') {
              callback(err);
            }
          });
      })
      .catch(function (err) {
        console.log(err)
      });
  }

}