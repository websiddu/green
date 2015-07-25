'use strict';

var express = require('express');
var passport = require('passport');
var config = require('../config/environment');
var User = require('../api/user/user.model');
var fs = require('fs');
var uwshib = require('passport-uwshib');


// require('./uwsaml/passport').setup(User, config);

var router = express.Router();

if(config.env === 'production') {

  var publicCert = fs.readFileSync(config.publicCert, 'utf-8');
  var privateKey = fs.readFileSync(config.privateKey, 'utf-8');
  var domain = config.domain || "green-certification.uw.edu";
  var entityId = config.entity || 'greenuw-certs1.s.uw.edu';
  var loginCallbackUrl = '/login/callback';

  var strategy = new uwshib.Strategy({
    entityId: entityId,
    privateKey: privateKey,
    callbackUrl: loginCallbackUrl,
    domain: domain,
    acceptedClockSkewMs: 300000
  });


  passport.use(strategy);

  passport.serializeUser(function(user, done){
    done(null, user);
  });

  passport.deserializeUser(function(user, done){
    done(null, user);
  });

  router.get('/', passport.authenticate(strategy.name), uwshib.backToUrl());
  router.post('/callback', passport.authenticate(strategy.name), function(req, res) {
    var url = defaultUrl || '/';
    if (req.session) {
        url = req.session.authRedirectUrl;
        delete req.session.authRedirectUrl;
    }
    res.redirect(url);
  });
  router.get(uwshib.urls.metadata, uwshib.metadataRoute(strategy, publicCert));

} else {
  require('./local/passport').setup(User, config);
  router.use('/local', require('./local'));
}

// router.use('/uwsaml', require('./uwsaml'));

module.exports = router;
