'use strict';

var express = require('express');
var passport = require('passport');
var config = require('../config/environment');
var User = require('../api/user/user.model');
var fs = require('fs');
var uwshib = require('passport-uwshib');
var auth = require('./auth.service');


// require('./uwsaml/passport').setup(User, config);

var router = express.Router();

if (config.env === 'production') {

  var publicCert = fs.readFileSync(config.publicCert, 'utf-8');
  var privateKey = fs.readFileSync(config.privateKey, 'utf-8');
  var domain = config.domain || "green-certification.uw.edu";
  var entityId = config.entity || 'https://green-certification.uw.edu';
  var loginCallbackUrl = '/login/callback';

  var strategy = new uwshib.Strategy({
    entityId: entityId,
    privateKey: privateKey,
    callbackUrl: loginCallbackUrl,
    domain: domain,
    acceptedClockSkewMs: 300000
  });

  passport.use(strategy);

  router.get('/', passport.authenticate(strategy.name), uwshib.backToUrl());
  router.post('/callback', passport.authenticate(strategy.name), auth.setTokenCookie);
  router.get(uwshib.urls.metadata, uwshib.metadataRoute(strategy, publicCert));

  passport.serializeUser(function(user, done) {
    User.findOne({
      email: user.netId + '@uw.edu',
    }, function(err, findeduser) {
      if (err) return done(err);

      if (!findeduser) {

        var newuser = new User({
          name: user.displayName,
          username: user.netId,
          email: user.netId + '@uw.edu',
          role: 'user',
          provider: 'saml'
        });

        newuser.save(function(err) {
          if (err) return done(err);
          return done(err, newuser);
        });

      } else {
        return done(null, findeduser);
      }
    });
  });

  passport.deserializeUser(function(user, done) {
    User.findOne({
      email: user.netId + '@uw.edu',
    }, function(err, findeduser) {
      if (err) return done(err);
      // if (!findeduser) {

      //   var newuser = new User({
      //     name: user.displayName,
      //     username: user.netId,
      //     email: user.netId + '@uw.edu',
      //     role: 'user',
      //     provider: 'saml'
      //   });

      //   newuser.save(function(err) {
      //     if (err) return done(err);
      //     return done(err, newuser);
      //   });

      // }
      return done(null, findeduser);
    });
  });


} else {

}

require('./local/passport').setup(User, config);
router.use('/local', require('./local'));

// router.use('/uwsaml', require('./uwsaml'));

module.exports = router;
