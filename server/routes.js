/**
 * Main application routes
 */

'use strict';

var errors = require('./components/errors');

module.exports = function(app) {

  // Insert routes below
  app.use('/api/certificates', require('./api/certificate'));
  app.use('/api/results', require('./api/result'));
  app.use('/api/choices', require('./api/choice'));
  app.use('/api/fields', require('./api/field'));
  app.use('/api/sections', require('./api/section'));
  app.use('/api/forms', require('./api/form'));
  app.use('/api/things', require('./api/thing'));
  app.use('/api/users', require('./api/user'));

  app.use('/auth', require('./auth'));

  // All undefined asset or api routes should return a 404
  app.route('/:url(api|auth|components|app|bower_components|assets)/*')
   .get(errors[404]);

  // All other routes should redirect to the index.html
  app.route('/*')
    .get(function(req, res) {
      res.sendfile(app.get('appPath') + '/index.html');
    });
};
